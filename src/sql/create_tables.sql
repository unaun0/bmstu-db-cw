-- Удаление всех отношений
DROP TABLE IF EXISTS "Attendance";
DROP TABLE IF EXISTS "Training";
DROP TABLE IF EXISTS "Membership";
DROP TABLE IF EXISTS "Payment";
DROP TABLE IF EXISTS "OrderItem";
DROP TABLE IF EXISTS "Order";
DROP TABLE IF EXISTS "TrainingRoom";
DROP TABLE IF EXISTS "MembershipType";
DROP TABLE IF EXISTS "TrainerSpecialization";
DROP TABLE IF EXISTS "Specialization";
DROP TABLE IF EXISTS "Trainer";
DROP TABLE IF EXISTS "UserRole";
DROP TABLE IF EXISTS "User";

-- Создание отношений

-- Пользователь
CREATE TABLE "User" (
    id 				UUID,
    email 			TEXT,
    phone_number 	TEXT,
    "password" 		TEXT,
    first_name 		TEXT,
    last_name 		TEXT,
	gender 			TEXT,
    birth_date 		DATE
);

-- Роль пользователя
CREATE TABLE "UserRole" (
    id			UUID,
	user_id		UUID,
    "role" 		TEXT
);

-- Тренер
CREATE TABLE "Trainer" (
    id 				UUID,
    user_id			UUID,
    description 	TEXT
);

-- Специализация
CREATE TABLE "Specialization" (
    id	 	UUID,
    name 	TEXT
);

-- Специализация тренера
CREATE TABLE "TrainerSpecialization" (
    id 					UUID,
    trainer_id			UUID,
    specialization_id	UUID,
	years				INT
);

-- Тип абонемента
CREATE TABLE "MembershipType" (
    id 			UUID,
    name 		TEXT,
    price 		NUMERIC,
    sessions	INT,
    days		INT
);

-- Зал для тренировок
CREATE TABLE "TrainingRoom" (
    id			UUID,
    name	 	TEXT,
    capacity 	INT
);

-- Заказ
CREATE TABLE "Order" (
    id 			UUID,
    user_id		UUID,
    "date" 		TIMESTAMP,
    total_price NUMERIC
);

-- Позиция заказа
CREATE TABLE "OrderItem" (
    id 					UUID,
    order_id 			UUID,
    membership_type_id 	UUID
);

-- Платеж
CREATE TABLE "Payment" (
    id				UUID,
    order_id		UUID,
    transaction_id 	TEXT,
    "date" 			TIMESTAMP,
    "method" 		TEXT,
	gateway 		TEXT,
    status 			TEXT
);
   
-- Абонемент
CREATE TABLE "Membership" (
    id 					UUID,
    user_id				UUID,
    order_id			UUID,
	membership_type_id	UUID,
	start_date			DATE,
	end_date			DATE,
    available_sessions	INT
);

-- Тренировка
CREATE TABLE "Training" (
    id 					UUID,
    specialization_id	UUID,
    room_id				UUID,
    trainer_id			UUID,
	"date"				TIMESTAMP
);

-- Посещение
CREATE TABLE "Attendance" (
    id 				UUID,
    membership_id	UUID,
    training_id		UUID,
    status			TEXT
);