DB_NAME = "fitnessClub"
DB_USER = "postgres"
DB_PASS = ""
DB_HOST = "localhost"
DB_PORT = "5432"

import psycopg2
import redis
import time
import json
from datetime import datetime
import random
from threading import Thread, Lock
import matplotlib.pyplot as plt
import os

output_dir = "grhs"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

conn = psycopg2.connect(
    dbname=DB_NAME, 
    user=DB_USER, 
    password=DB_PASS, 
    host=DB_HOST, 
    port=DB_PORT
)
cursor = conn.cursor()
flag = True
r = redis.Redis(
    host='localhost', 
    port=6379, db=0, 
    password='1210'
)
cache_durations = []
db_durations = []

def get_spec_from_db():
    cursor.execute("""
        SELECT * 
        FROM "User" u
        JOIN "Membership" m on m.user_id = u.id
        JOIN "Order" o on o.id = m.order_id
        WHERE birth_date > '2003-01-01' AND gender = 'женский'
        ORDER BY birth_date DESC;
    """)
    try:
        return cursor.fetchall()
    except:
        return None

def cache_spec():
    spec = get_spec_from_db()
    r.setex('spec', 60, str(spec))

def get_spec_from_cache():
    global flag
    cached_data = r.get('spec')
    if cached_data: #and flag:
        return cached_data
    else:
        #flag = True
        cache_spec()
        return get_spec_from_cache()

def cache_query():
    for _ in range(10):
        start_time = time.time()
        get_spec_from_cache()
        duration = time.time() - start_time
        cache_durations.append(duration)
        time.sleep(1)

def db_query():
    for _ in range(10):
        start_time = time.time()
        get_spec_from_db()
        duration = time.time() - start_time
        db_durations.append(duration)
        time.sleep(1)

def graph_just():
    global cache_durations, db_durations, flag
    cache_durations, db_durations = [], []
    flag = True

    cache_thread = Thread(target=cache_query)
    db_thread = Thread(target=db_query)

    cache_thread.start()
    db_thread.start()

    cache_thread.join()
    db_thread.join()

    avg_cache_duration = sum(cache_durations) / len(cache_durations)
    avg_db_duration = sum(db_durations) / len(db_durations)

    print("Среднее время выполнения запроса к кэшу:", avg_cache_duration)
    print("Среднее время выполнения запроса к базе данных:", avg_db_duration)

    labels = ['Кэш', 'БД']
    avg_durations = [avg_cache_duration, avg_db_duration]

    plt.figure(figsize=(8, 6))
    plt.bar(labels, avg_durations, color=['blue', 'green'], edgecolor='black')

    plt.title('Среднее время выполнения запросов')
    plt.ylabel('Время (сек)')
    plt.xlabel('Тип запроса')

    for i, value in enumerate(avg_durations):
        plt.text(i, value + 0.01, f'{value:.6f}', ha='center', va='bottom')

    plt.savefig(os.path.join(output_dir, 'just.png'))
    plt.close()

    print(f"График сохранён в папку {output_dir} под именем 'just.png'")

if __name__ == '__main__':
   graph_just()

cursor.close()
conn.close()