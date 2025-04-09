import csv
from faker import Faker
import random
import uuid
from datetime import datetime, timedelta
import os
import bcrypt

fake = Faker('ru_RU')
fakeEN = Faker('en_US') 
salt = bcrypt.gensalt()

data_folder = './data'
os.makedirs(data_folder, exist_ok=True)

spec_names = [
    "Кроссфит",
    "Функциональный тренинг",
    "Силовой фитнес",
    "Кардио-фитнес",
    "Стретчинг",
    "Пилатес",
    "Аэробика",
    "Танцевальный фитнес (Zumba, Latina, Hip-Hop Fitness)",
    "Аквафитнес",
    "Барре-фитнес",
    "Хатха-йога",
    "Аштанга-йога",
    "Виньяса-йога",
    "Айенгар-йога",
    "Йога-нидра",
    "Кундалини-йога",
    "Бикрам-йога (горячая йога)",
    "Йога для беременных",
    "Йога-терапия",
    "Йога-флоу"
]

# Генерация случайной даты в пределах от start_date до end_date
def generate_random_date(start_date, end_date):
    delta = end_date - start_date
    random_days = random.randint(0, delta.days)
    return start_date + timedelta(days=random_days)

# Генерация случайного времени в пределах определенного интервала
def generate_random_time(start_hour, end_hour):
    random_minute = random.randint(0, 59)
    random_hour = random.randint(start_hour, end_hour)
    return datetime.combine(datetime.today(), datetime.min.time()) + timedelta(hours=random_hour, minutes=random_minute)

# Генерация интервала дат
def generate_random_dates():
    # Текущая дата
    now = datetime.now()

    # Генерация случайной даты начала (раньше текущей)
    random_days_past = random.randint(1, 365)
    start_date = now - timedelta(days=random_days_past)

    # Генерация случайной даты конца (позже start_date)
    random_days_future = random.randint(1, 365)
    end_date = start_date + timedelta(days=random_days_future)

    # Возвращаем даты в формате "YYYY-MM-DD"
    return start_date.date(), end_date.date()

# Генерация номера телефона
def generate_phone_number():
    country_code = random.choice(['+7', '+1', '+44', '+33', '+49'])
    number = ''.join(random.choices('0123456789', k=10))
    return f"{country_code}{number}"

# Генерация пользователей
def generate_users(num):
    users = []
    for _ in range(num):
        gender = random.choice(["мужской", "женский"])
        first_name, last_name = None, None
        if gender == "мужской":
            first_name = fake.first_name_male()
            last_name = fake.last_name_male()
        else:
            first_name = fake.first_name_female()
            last_name = fake.last_name_female()
        user = [
            str(uuid.uuid4()),
            fake.email(),
            generate_phone_number(),
            str(
                bcrypt.hashpw(
                    fake.password().encode('utf-8'), 
                    salt
                )
            ),                                                     
            first_name,
            last_name,
            fake.date_of_birth(
                minimum_age=14, 
                maximum_age=75
            ),
            gender
        ]
        users.append(user)
    return users

# Генерация ролей пользователей
def generate_user_roles(users):
    roles = ['клиент', 'тренер', 'администратор']
    user_roles = []
    for user in users:
        user_role = [
            str(uuid.uuid4()),   
            random.choice(roles),
            user[0]               
        ]
        user_roles.append(user_role)
    return user_roles

# Генерация тренеров
def generate_trainers(users_role):
    trainers = []
    for ur in users_role:
        if ur[1] != 'тренер':
            continue
        trainer = [
            str(uuid.uuid4()),
            ur[2],
            fake.text(
                max_nb_chars=500
            )
        ]
        trainers.append(trainer)
    return trainers

# Генерация специализаций
def generate_specializations():
    specializations = []
    for sp in spec_names:
        specialization = [
            str(uuid.uuid4()),
            sp
        ]
        specializations.append(specialization)
    return specializations

# Генерация типов абонементов
def generate_membership_types():
    membership_types = [
        [str(uuid.uuid4()), "Базовый", random.uniform(10000, 15000), 10, 30],
        [str(uuid.uuid4()), "Продвинутый", random.uniform(15000, 20000), 20, 60],
        [str(uuid.uuid4()), "Премиум", random.uniform(20000, 30000), 30, 90],
        [str(uuid.uuid4()), "VIP", random.uniform(40000, 50000), 60, 180],
        [str(uuid.uuid4()), "Элитный", random.uniform(50000, 100000), 120, 365],
        [str(uuid.uuid4()), "Разовый", random.uniform(500, 1000), 1, 7],
        [str(uuid.uuid4()), "Пробный", random.uniform(1000, 2000), 2, 14],
        [str(uuid.uuid4()), "Гибкий", random.uniform(25000, 45000), 12, 45],
        [str(uuid.uuid4()), "Корпоративный", random.uniform(30000, 60000), 45, 90],
        [str(uuid.uuid4()), "Семейный", random.uniform(35000, 65000), 30, 90],
        [str(uuid.uuid4()), "Безлимитный", random.uniform(70000, 10000), 365, 365],
        [str(uuid.uuid4()), "Полугодовой", random.uniform(60000, 90000), 100, 180],
        [str(uuid.uuid4()), "Годовой", random.uniform(120000, 180000), 200, 365],
        [str(uuid.uuid4()), "Клубная карта", random.uniform(150000, 200000), 730, 730],
        [str(uuid.uuid4()), "Персональный", random.uniform(50000, 80000), 20, 60],
        [str(uuid.uuid4()), "Индивидуальный", random.uniform(60000, 90000), 25, 90],
        [str(uuid.uuid4()), "Экспресс", random.uniform(20000, 30500), 12, 30],
        [str(uuid.uuid4()), "Специальный", random.uniform(40000, 60000), 18, 60],
        [str(uuid.uuid4()), "Флекс", random.uniform(30000, 50000), 15, 45],
        [str(uuid.uuid4()), "VIP Премиум", random.uniform(80000, 120000), 50, 365]
    ]
    return membership_types

# Генерация залов
def generate_training_rooms(num):
    rooms = []
    for i in range(1, num + 1):
        room = [
            str(uuid.uuid4()),
            f'Зал №{i}',
            random.randint(3, 10)
        ]
        rooms.append(room)
    return rooms

# Генерация специализаций для тренеров
def generate_trainer_specializations(trainers, specializations):
    trainer_specializations = []
    for tr in trainers:
        num_specializations = random.randint(1, 5)
        selected_specializations = random.sample(specializations, num_specializations)
        for specialization in selected_specializations:
            trainer_specializations.append([
                str(uuid.uuid4()),
                tr[0],
                specialization[0], 
                random.randint(0, 25)
            ])
    return trainer_specializations

# Генерация заказов, платежей и абонементов
def generate_orders_and_payments(users, membership_types, num_orders):
    orders = []
    order_items = []
    payments = []
    memberships = []
    for _ in range(num_orders):
        user_id = random.choice(users)[0]
        start_date, end_date = generate_random_dates()
        # Генерация заказа
        order_id = str(uuid.uuid4())
        total_price = 0
        num_items = random.randint(1, 5)  # Количество позиций в заказе (абонементов)
        
        # Генерация позиций заказов
        for _ in range(num_items):
            membership = random.choice(membership_types)  # Выбираем случайный тип абонемента
            order_items.append([
                str(uuid.uuid4()),  # id
                order_id,            # order_id
                membership[0],       # membership_type_id
            ])
            total_price += membership[2]  # Добавляем цену выбранного абонемента
        
        # Генерация заказа с актуальной суммой
        orders.append([
            order_id,                    # id
            user_id,                     # user_id
            start_date,              # order_date
            total_price,                 # total_price
        ])
        # Генерация платежа для заказа
        payment_method = random.choice(['наличные', 'кредитная карта', 'банковский перевод'])
        payment_gateway = fakeEN.word() if payment_method == 'кредитная карта' else None
        payment_status = random.choice(['ожидает', 'оплачен', 'отменен'])
        payment = [
            str(uuid.uuid4()),
            order_id,
            str(uuid.uuid4()),
            start_date,
            payment_method,
            payment_gateway,
            payment_status
        ]
        payments.append(payment)
        if payment_status == 'оплачен':
            order_item = random.choice(order_items)
            membership_type_id = order_item[2]
            membership = [
                str(uuid.uuid4()),
                user_id,
                membership_type_id,
                order_id,
                start_date,
                start_date + timedelta(days=random.randint(7, 360)),
                random.randint(1, 100)
            ]
            memberships.append(membership)
    return orders, order_items, payments, memberships

# Генерация данных для тренировок
def generate_trainings(trainer_specializations, training_rooms, num_trainings):
    trainings = []
    start_date = datetime.now().date()
    end_date = start_date + timedelta(days=30)
    for _ in range(num_trainings):
        trainer_specialization = random.choice(trainer_specializations)
        trainer_id = trainer_specialization[1]
        specialization_id = trainer_specialization[2]
        room_id = random.choice(training_rooms)[0]
        date = str(generate_random_date(start_date, end_date))
        time = str(generate_random_time(8, 22).time())
        datetime_str = f"{date} {time}"
        training = [
            str(uuid.uuid4()),
            datetime.strptime(datetime_str, "%Y-%m-%d %H:%M:%S"),
            specialization_id,
            room_id,
            trainer_id
        ]
        trainings.append(training)
    return trainings

# Генерация данных посещений
def generate_attendances(memberships, trainings, num_attendances, max_attempts=100):
    attendance_status = ['посетил', 'отсутствовал', 'ожидает']
    attendances = []
    existing_combinations = set()
    for _ in range(num_attendances):
        attempts = 0
        membership = random.choice(memberships)
        training = random.choice(trainings)
        while (membership[0], training[0]) in existing_combinations and attempts < max_attempts:
            training = random.choice(trainings)
            attempts += 1
        if attempts >= max_attempts:
            break
        status = random.choice(attendance_status)
        attendance = [
            str(uuid.uuid4()), 
            membership[0],
            training[0],
            status
        ]
        attendances.append(attendance)
        existing_combinations.add((membership[0], training[0]))
    return attendances

# Запись данных в CSV файлы
def write_to_csv(filename, data):
    with open(os.path.join(data_folder, filename), mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow([])
        writer.writerows(data)


# Генерация данных
users = generate_users(200)
write_to_csv('user.csv', users)
print("Данные для User успешно записаны в CSV файл 'data/user.csv'!")

user_roles = generate_user_roles(users)
write_to_csv('user_role.csv', user_roles)
print("Данные для UserRole успешно записаны в CSV файл 'data/user_role.csv'!")

trainers = generate_trainers(user_roles)
write_to_csv('trainer.csv', trainers)
print("Данные для Trainer успешно записаны в CSV файл 'data/trainer.csv'!")

specializations = generate_specializations()
write_to_csv('specialization.csv', specializations)
print("Данные для Specialization успешно записаны в CSV файл 'data/specialization.csv'!")

trainer_specializations = generate_trainer_specializations(trainers, specializations)
write_to_csv('trainer_specialization.csv', trainer_specializations)
print("Данные для TrainerSpecialization успешно записаны в CSV файл 'data/trainer_specialization.csv'!")

membership_types = generate_membership_types()
write_to_csv('membership_type.csv', membership_types)
print("Данные для MembershipType успешно записаны в CSV файл 'data/membership_type.csv'!")

rooms = generate_training_rooms(20)
write_to_csv('training_room.csv', rooms)
print("Данные для TrainingRoom успешно записаны в CSV файл 'data/training_room.csv'!")

orders, order_items, payments, memberships = generate_orders_and_payments(users, membership_types, 100)
write_to_csv('order.csv', orders)
write_to_csv('order_item.csv', order_items)
write_to_csv('payment.csv', payments)
write_to_csv('membership.csv', memberships)
print("Данные для Order, OrderItem, Payment, Membership успешно записаны в CSV файлы в папке 'data'!")

trainings = generate_trainings(trainer_specializations, rooms, 50)
write_to_csv('training.csv', trainings)
print("Данные для Training успешно записаны в CSV файл 'data/training.csv'!")

attendances = generate_attendances(memberships, trainings, 70)
write_to_csv('attendance.csv', attendances)
print("Данные для Attendance успешно записаны в CSV файл 'data/attendance.csv'!")

print("ВСЕ данные успешно записаны в CSV файлы в папке 'data'!")
