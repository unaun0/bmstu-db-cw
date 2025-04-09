import psycopg2
import threading
import time
from statistics import mean

# Параметры подключения к БД
db_config = {
    "dbname": "fitnessClub",
    "user": "postgres",
    "password": "",
    "host": "localhost",
    "port": "5432"
}

CONCURRENT_REQUESTS = [1, 10, 25, 50, 75]
TEST_DURATION = 10  # секунд
QUERY = "SELECT * FROM \"User\" WHERE gender = 'мужской';"
output_file = "concurrent-test-results.txt"

def run_queries(duration, times):
    conn = psycopg2.connect(**db_config)
    cur = conn.cursor()
    end_time = time.time() + duration
    latencies = []

    while time.time() < end_time:
        start = time.time()
        cur.execute(QUERY)
        cur.fetchall()
        latency = (time.time() - start) * 1000  # мс
        latencies.append(latency)
    conn.close()
    times.extend(latencies)

def test_concurrent_clients(n_clients):
    all_latencies = []
    threads = []

    for _ in range(n_clients):
        t = threading.Thread(target=run_queries, args=(TEST_DURATION, all_latencies))
        t.start()
        threads.append(t)

    for t in threads:
        t.join()

    if all_latencies:
        avg_latency = mean(all_latencies)
        total_requests = len(all_latencies)
        result = f"{n_clients} {avg_latency:.2f} {total_requests}"
        print(f"[{n_clients} клиентов] Среднее время отклика: {avg_latency:.6f} мс, запросов: {total_requests}")
        with open(output_file, "a", encoding="utf-8") as f:
            f.write(result + "\n")
    else:
        print(f"[{n_clients} клиентов] Нет данных")

if __name__ == "__main__":
    with open(output_file, "w", encoding="utf-8") as f:
        f.write("Клиенты Среднее Время(мс) Запросов\n")

    for clients in CONCURRENT_REQUESTS:
        test_concurrent_clients(clients)
