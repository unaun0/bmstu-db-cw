-- Создание ограничений целостности данных

-- Пользователь
ALTER TABLE "User"
	-- id
    ADD CONSTRAINT "pk:user.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- email
    ADD CONSTRAINT "chk:user.email:notnull" CHECK (
		email IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.email:length" CHECK (
		length(email) < 128
	),
	ADD CONSTRAINT "chk:user.email:regexp" CHECK (
		email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'
	),
	ADD CONSTRAINT "uq:user.email" UNIQUE (email),
	-- phone_number
	ADD CONSTRAINT "chk:user.phone_number:notnull" CHECK (
		phone_number IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.phone_number:length" CHECK (
		length(phone_number) < 32
	),
	ADD CONSTRAINT "chk:user.phone_number:regexp" CHECK (
		phone_number ~ '^\+\d{10,15}$'
	),
	ADD CONSTRAINT "uq:user.phone_number" UNIQUE (phone_number),
	-- password
    ADD CONSTRAINT "chk:user.password:notnull" CHECK (
		"password" IS NOT NULL
	),
	-- first_name
    ADD CONSTRAINT "chk:user.first_name:notnull" CHECK (
		first_name IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.first_name:length" CHECK (
		length(first_name) < 128
	),
	ADD CONSTRAINT "chk:user.first_name:regexp" CHECK (
		first_name ~ '^([a-zA-Zа-яА-ЯёЁ]+(?:-[a-zA-Zа-яА-ЯёЁ]+)?)$'
	),
	-- last_name
    ADD CONSTRAINT "chk:user.last_name:notnull" CHECK (
		last_name IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.last_name:length" CHECK (
		length(last_name) < 128
	),
	ADD CONSTRAINT "chk:user.last_name:regexp" CHECK (
		last_name ~ '^([a-zA-Zа-яА-ЯёЁ]+(?:-[a-zA-Zа-яА-ЯёЁ]+)?)$'
	),
	-- gender
    ADD CONSTRAINT "chk:user.gender:notnull" CHECK (
		gender IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.gender:length" CHECK (
		length(gender) < 32
	),
	ADD CONSTRAINT "chk:user.gender:regexp" CHECK (
		gender IN ('мужской', 'женский')
	),
	-- birth_date
    ADD CONSTRAINT "chk:user.birth_date:notnull" CHECK (
		birth_date IS NOT NULL
	),
	ADD CONSTRAINT "chk:user.birth_date" CHECK (
	    birth_date >= CURRENT_DATE - INTERVAL '120 years' AND
	    birth_date <= CURRENT_DATE - INTERVAL '14 years'
	);

-- Роль пользователя
ALTER TABLE "UserRole"
	-- id
    ADD CONSTRAINT "pk:user_role.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- user_id
	ADD CONSTRAINT "fk:user_role.user_id" FOREIGN KEY (user_id) 
        REFERENCES "User"(id) ON DELETE CASCADE,
    ADD CONSTRAINT "uq:user_role.user_id" UNIQUE (user_id),
	-- role
	ADD CONSTRAINT "chk:user_role.role:notnull" CHECK (
		"role" IS NOT NULL
	),
	ADD CONSTRAINT "chk:user_role.role:length" CHECK (
		length("role") < 32
	),
	ADD CONSTRAINT "chk:user_role.role:regexp" CHECK (
        "role" IN ('клиент', 'тренер', 'администратор')
    );

-- Тренер
ALTER TABLE "Trainer"
	-- id
	ADD CONSTRAINT "pk:trainer.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- user_id
    ADD CONSTRAINT "fk:trainer.user_id" FOREIGN KEY (user_id) 
        REFERENCES "User"(id) ON DELETE CASCADE,
    ADD CONSTRAINT "uq:trainer.user_id" UNIQUE (user_id),
	-- description
	ALTER COLUMN "description" SET DEFAULT 'Нет описания.',
	ADD CONSTRAINT "chk:trainer.description:notnull" CHECK (
		description IS NOT NULL
	),
	ADD CONSTRAINT "chk:trainer.description:length" CHECK (
		length(description) < 512
	);

-- Специализация
ALTER TABLE "Specialization"
	-- id
	ADD CONSTRAINT "pk:specialization.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- name
	ADD CONSTRAINT "chk:specialization.name:notnull" CHECK (
		name IS NOT NULL
	),
    ADD CONSTRAINT "chk:specialization.name:length" CHECK (
		length(name) < 128
	),
    ADD CONSTRAINT "uq:specialization.name" UNIQUE (name);

-- Специализация тренера
ALTER TABLE "TrainerSpecialization"
	-- id
	ADD CONSTRAINT "pk:trainer_specialization.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- trainer_id
	ADD CONSTRAINT "fk:trainer_specialization.trainer_id" 
		FOREIGN KEY (trainer_id) 
        REFERENCES "Trainer"(id) ON DELETE CASCADE,
	-- specialization_id
	ADD CONSTRAINT "fk:trainer_specialization.specialization_id" 
		FOREIGN KEY (specialization_id) 
        REFERENCES "Specialization"(id) ON DELETE CASCADE,
    ADD CONSTRAINT "uq:trainer_specialization.trainer+specialization" 
		UNIQUE (trainer_id, specialization_id),
	-- years
	ALTER COLUMN years SET DEFAULT 0,
	ADD CONSTRAINT "chk:trainer_specialization.years:notnull" CHECK (
		years IS NOT NULL
	),
    ADD CONSTRAINT "chk:specialization.name:unsigned" CHECK (
		years >= 0
	);

-- Тип абонемента
ALTER TABLE "MembershipType"
	-- id
	ADD CONSTRAINT "pk:membership_type.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- name
	ADD CONSTRAINT "chk:membership_type.name:notnull" CHECK (
		name IS NOT NULL
	),
    ADD CONSTRAINT "chk:membership_type.name:length" CHECK (
		length(name) < 128
	),
	ADD CONSTRAINT "uq:membership_type.name" UNIQUE (name),
	-- price
	ALTER COLUMN price SET DEFAULT 0.0,
	ADD CONSTRAINT "chk:membership_type.price:notnull" CHECK (
		price IS NOT NULL
	),
    ADD CONSTRAINT "chk:membership_type.price:unsigned" CHECK (
		price >= 0.0
	),
	-- sessions
	ALTER COLUMN sessions SET DEFAULT 1,
	ADD CONSTRAINT "chk:membership_type.sessions:notnull" CHECK (
		sessions IS NOT NULL
	),
    ADD CONSTRAINT "chk:membership_type.sessions:unsigned" CHECK (
		sessions > 0
	),
	-- days
	ALTER COLUMN days SET DEFAULT 1,
	ADD CONSTRAINT "chk:membership_type.days:notnull" CHECK (
		days IS NOT NULL
	),
    ADD CONSTRAINT "chk:membership_type.days:unsigned" CHECK (
		days > 0
	);

-- Зал для тренировок
ALTER TABLE "TrainingRoom"
	-- id
	ADD CONSTRAINT "pk:training_room.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- name
	ADD CONSTRAINT "chk:training_room.name:notnull" CHECK (
		name IS NOT NULL
	),
    ADD CONSTRAINT "chk:training_room.name:length" CHECK (
		length(name) < 64
	),
	ADD CONSTRAINT "uq:training_room.name" UNIQUE (name),
	-- capacity
	ADD CONSTRAINT "chk:training_room.capacity:notnull" CHECK (
		capacity IS NOT NULL
	),
    ADD CONSTRAINT "chk:training_room.capacity" CHECK (capacity > 0);

-- Заказ
ALTER TABLE "Order"
	-- id
	ADD CONSTRAINT "pk:order.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- user_id
    ADD CONSTRAINT "fk:order.user_id" FOREIGN KEY (user_id) 
		REFERENCES "User"(id) ON DELETE SET NULL,
	-- date
	ALTER COLUMN "date" SET DEFAULT CURRENT_TIMESTAMP,
	ADD CONSTRAINT "chk:order.date:notnull" CHECK (
		"date" IS NOT NULL
	),
	-- total_price
	ALTER COLUMN total_price SET DEFAULT 0.0,
	ADD CONSTRAINT "chk:order.total_price:notnull" CHECK (
		total_price IS NOT NULL
	),
    ADD CONSTRAINT "chk:order.total_price:unsigned" CHECK (
		total_price >= 0.0
	);

-- Позиция заказа
ALTER TABLE "OrderItem"
	-- id
	ADD CONSTRAINT "pk:order_item.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- order_id
	ADD CONSTRAINT "fk:order_item.order_id" FOREIGN KEY (order_id) 
		REFERENCES "Order"(id) ON DELETE CASCADE,
	-- membership_type_id
	ADD CONSTRAINT "fk:order_item.membership_type_id" 
		FOREIGN KEY (membership_type_id) 
		REFERENCES "MembershipType"(id) ON DELETE CASCADE;

-- Платеж
ALTER TABLE "Payment"
	-- id
	ADD CONSTRAINT "pk:payment.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- order_id
	ADD CONSTRAINT "fk:payment.order_id" FOREIGN KEY (order_id) 
		REFERENCES "Order"(id) ON DELETE SET NULL,
	-- transaction_id
	ADD CONSTRAINT "chk:payment.transaction_id:notnull" CHECK (
		transaction_id IS NOT NULL
	),
    ADD CONSTRAINT "chk:payment.transaction_id:length" CHECK (
		length(transaction_id) < 256
	),
	ADD CONSTRAINT "uq:payment.transaction_id" UNIQUE (transaction_id),
	-- date
	ALTER COLUMN "date" SET DEFAULT CURRENT_TIMESTAMP,
	ADD CONSTRAINT "chk:payment.date:notnull" CHECK (
		"date" IS NOT NULL
	),
	-- method
	ALTER COLUMN "method" SET DEFAULT 'наличные',
	ADD CONSTRAINT "chk:payment.method:notnull" CHECK (
		"method" IS NOT NULL
	),
	ADD CONSTRAINT "chk:payment.method:length" CHECK (
		length("method") < 64
	),
	ADD CONSTRAINT "chk:payment.method:regexp" CHECK (
		"method" IN ('наличные', 'кредитная карта', 'банковский перевод')
	),
	-- gateway
	ALTER COLUMN "gateway" SET DEFAULT NULL,
	ADD CONSTRAINT "chk:payment.gateway:length" CHECK (
		length("gateway") < 64
	),
	-- status
	ALTER COLUMN "status" SET DEFAULT 'ожидает',
	ADD CONSTRAINT "chk:payment.status:notnull" CHECK (
		"status" IS NOT NULL
	),
	ADD CONSTRAINT "chk:payment.status:length" CHECK (
		length("status") < 64
	),
    ADD CONSTRAINT "chk:payment.status" CHECK (
		status IN ('ожидает', 'оплачен', 'отменен')
	);
   
-- Абонемент
ALTER TABLE "Membership"
	-- id
	ADD CONSTRAINT "pk:membership.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- user_id
	ADD CONSTRAINT "fk:membership.user_id" FOREIGN KEY (user_id) 
		REFERENCES "User"(id) ON DELETE CASCADE,
	-- order_id
	ADD CONSTRAINT "fk:membership.order_id" FOREIGN KEY (order_id) 
		REFERENCES "Order"(id) ON DELETE SET NULL,
	-- membership_type_id
	ADD CONSTRAINT "fk:membership.membership_type_id" 
		FOREIGN KEY (membership_type_id) 
		REFERENCES "MembershipType"(id) ON DELETE SET NULL,
	ADD CONSTRAINT "uq:membership.membership_type+user"
		UNIQUE(membership_type_id, user_id),
	-- start_date
	ALTER COLUMN start_date SET DEFAULT NULL,
	-- end_date
	ALTER COLUMN end_date SET DEFAULT NULL,
	ADD CONSTRAINT "chk:membership.dates:order" CHECK (
    	(start_date IS NULL AND end_date IS NULL) 
		OR (
			start_date IS NOT NULL and end_date IS NOT NULL 
			AND start_date <= end_date
		)
	),
	-- available_sessions
	ALTER COLUMN available_sessions SET DEFAULT 0,
	ADD CONSTRAINT "chk:membership.available_sessions:notnull" CHECK (
		available_sessions IS NOT NULL
	),
    ADD CONSTRAINT "chk:membership.available_sessions:unsigned" CHECK (
		available_sessions >= 0
	);

-- Тренировка
ALTER TABLE "Training"
	-- id 
	ADD CONSTRAINT "pk:training.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- specialization_id
	ADD CONSTRAINT "fk:training.specialization_id" 
		FOREIGN KEY (specialization_id) 
		REFERENCES "Specialization"(id) ON DELETE SET NULL,
	-- room_id
	ADD CONSTRAINT "fk:training.room_id" 
		FOREIGN KEY (room_id) 
		REFERENCES "TrainingRoom"(id) ON DELETE SET NULL,
	-- trainer_id
	ADD CONSTRAINT "fk:training.trainer_id" 
		FOREIGN KEY (trainer_id) 
		REFERENCES "Trainer"(id) ON DELETE SET NULL,
	-- date
	ALTER COLUMN "date" SET DEFAULT CURRENT_TIMESTAMP,
	ADD CONSTRAINT "chk:training.date:notnull" CHECK (
		"date" IS NOT NULL
	);

-- Посещение
ALTER TABLE "Attendance"
	-- id 
	ADD CONSTRAINT "pk:attendance.id" PRIMARY KEY (id),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
	-- membership_id
	ADD CONSTRAINT "fk:attendance.membership_id" 
		FOREIGN KEY (membership_id) 
		REFERENCES "Membership"(id) ON DELETE CASCADE,
	-- training_id
	ADD CONSTRAINT "fk:attendance.training_id" 
		FOREIGN KEY (training_id) 
		REFERENCES "Training"(id) ON DELETE SET NULL,
	ADD CONSTRAINT "uq:attendance.membership+training" 
		UNIQUE (membership_id, training_id),
	-- status
	ALTER COLUMN status SET DEFAULT 'ожидает',
	ADD CONSTRAINT "chk:attendance.status:notnull" CHECK (
		status IS NOT NULL
	),
	ADD CONSTRAINT "chk:attendance.status:length" CHECK (
		length(status) < 64
	),
    ADD CONSTRAINT "chk:attendance.status:regexp" CHECK (
		status IN ('посетил', 'отсутствовал', 'ожидает')
	);



