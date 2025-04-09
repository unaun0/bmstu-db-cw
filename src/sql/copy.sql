-- Добавление тестовых сгенерированных данных

-- Пользователь
COPY "User"(id, email, phone_number, "password", first_name, last_name, birth_date, gender)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/user.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * FROM "User";

-- Роль пользователя
COPY "UserRole"(id, role, user_id)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/user_role.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * FROM "UserRole";

-- Тренер
COPY "Trainer"(id, user_id, description)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/trainer.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * FROM "Trainer";

-- Специализация
COPY "Specialization"(id, name)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/specialization.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * FROM "Specialization";

-- Специализация тренера
COPY "TrainerSpecialization"(id, trainer_id, specialization_id, years)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/trainer_specialization.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * FROM "TrainerSpecialization";

-- Тип абонемента
COPY "MembershipType"(id, name, price, sessions, days)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/membership_type.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * FROM "MembershipType";

-- Зал
COPY "TrainingRoom"(id, name, capacity)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/training_room.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * FROM "TrainingRoom";

-- Заказ
COPY "Order"(id, user_id, "date", total_price)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/order.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * FROM "Order";

-- Позиция заказа
COPY "OrderItem"(id, order_id, membership_type_id)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/order_item.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * from "OrderItem";

-- Платеж
COPY "Payment"(id, order_id, transaction_id, "date", "method", "gateway", status)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/payment.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * FROM "Payment";

-- Абонемент
COPY "Membership"(id, user_id, membership_type_id, order_id, start_date, end_date, available_sessions)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/membership.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * from "Membership";

-- Тренировка
COPY "Training"(id, "date", specialization_id, room_id, trainer_id)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/training.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * from "Training";

-- Посещение
COPY "Attendance"(id, membership_id, training_id, status)
FROM '/Users/tsyar/Desktop/bmstu/bmstu-db/src/data/attendance.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
SELECT * from "Attendance";