import psycopg2
import time
import uuid
import random
from datetime import date, timedelta
import csv

conn = psycopg2.connect(
    dbname="fitnessClub",
    user="postgres",
    password="",
    host="localhost",
    port="5432"
)
cur = conn.cursor()

data_sizes = [10, 25, 50, 100, 250, 500, 750, 1000]

insert_results = []
select_results = []
update_results = []
delete_results = []

# Очистим таблицу перед началом
cur.execute('DELETE FROM "User"')
conn.commit()

all_users = []

def generate_user(i):
    uid = str(uuid.uuid4())
    email = f"user{i}_{uuid.uuid4().hex[:5]}@example.com"
    phone = f"+79{random.randint(100000000, 999999999)}"
    password = "secure_password"
    first_name = f"Имя"
    last_name = f"Фамилия"
    gender = random.choice(["мужской", "женский"])
    birth_date = date.today() - timedelta(days=random.randint(10110, 20800))
    return (uid, email, phone, password, first_name, last_name, gender, birth_date)

# Функция для вставки с уникальностью id
def insert_user_safe(user):
    while True:
        try:
            cur.execute("""INSERT INTO "User" (id, email, phone_number, password, first_name, last_name, gender, birth_date)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""", user)
            conn.commit()
            break
        except psycopg2.errors.UniqueViolation:
            # Если возникает ошибка уникальности, генерируем новый id
            user = generate_user(random.randint(1000000, 9999999))  # Генерируем новый уникальный пользователь
            conn.rollback()  # Откатываем транзакцию перед повторной попыткой
            continue

for size in data_sizes:
    # Добавляем пользователей до нужного количества
    new_users = [generate_user(len(all_users) + i) for i in range(size - len(all_users))]
    for user in new_users:
        insert_user_safe(user)  # Вставляем пользователя с проверкой на уникальность
    all_users.extend(new_users)

    # Вставка уже выполнена выше, но замерим время для интереса
    start = time.time()
    for user in new_users:
        insert_user_safe(user)
    conn.rollback()  # Откатываем вставку, чтобы не дублировать
    insert_time = time.time() - start
    insert_results.append((size, insert_time))

    # SELECT
    start = time.time()
    cur.execute("""SELECT * FROM "User" ORDER BY RANDOM() LIMIT %s""", (size,))
    cur.fetchall()
    select_time = time.time() - start
    select_results.append((size, select_time))

    # UPDATE
    start = time.time()
    for user in all_users[:size]:
        cur.execute("""UPDATE "User" SET first_name = %s WHERE id = %s""", ("Обновлено", user[0]))
    conn.commit()
    update_time = time.time() - start
    update_results.append((size, update_time))

    # DELETE
    start = time.time()
    for user in all_users[:size]:
        cur.execute("""DELETE FROM "User" WHERE id = %s""", (user[0],))
    conn.rollback()  # Откатываем удаление, чтобы сохранить пользователей
    delete_time = time.time() - start
    delete_results.append((size, delete_time))

def save_to_csv(filename, data):
    with open(filename, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Size", "Time (s)"])
        writer.writerows(data)

save_to_csv("insert_results.csv", insert_results)
save_to_csv("select_results.csv", select_results)
save_to_csv("update_results.csv", update_results)
save_to_csv("delete_results.csv", delete_results)

cur.close()
conn.close()
