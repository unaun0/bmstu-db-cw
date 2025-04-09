-- Триггер для автоматического обновления доступных тренировок 
-- после посещения тренировки
CREATE OR REPLACE FUNCTION update_available_sessions()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.status = 'посетил' OR NEW.status = 'отсутствовал') 
		AND (OLD.status <> 'посетил' AND OLD.status <> 'отсутствовал') 
	THEN
        UPDATE "Membership"
        SET available_sessions = available_sessions - 1
        WHERE id = NEW.membership_id;
    ELSIF (NEW.status = 'ожидает') 
		AND (OLD.status = 'посетил' OR OLD.status = 'отсутствовал') 
	THEN
        UPDATE "Membership"
        SET available_sessions = available_sessions + 1
        WHERE id = NEW.membership_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER attendance_status_update
AFTER UPDATE OF status ON "Attendance"
FOR EACH ROW
EXECUTE FUNCTION update_available_sessions();

-- Тригер для записи на тренировку с учетом проверки количества 
-- доступных мест
CREATE OR REPLACE FUNCTION check_room_capacity()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') 
		OR (TG_OP = 'UPDATE' 
		AND NEW.training_id IS DISTINCT 
			FROM OLD.training_id) 
	THEN
        IF (
            SELECT COUNT(*) 
            FROM "Attendance"
            WHERE training_id = NEW.training_id
        ) >= (
            SELECT capacity 
            FROM "TrainingRoom"
            WHERE id = (
                SELECT room_id 
                FROM "Training"
                WHERE id = NEW.training_id
            )
        )
        THEN
            RAISE EXCEPTION 'Тренировка уже заполнена';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER check_room_capacity_trigger
BEFORE INSERT ON "Attendance"
FOR EACH ROW
EXECUTE FUNCTION check_room_capacity();

-- Триггер для создания абонемента или продления его после успешного платежа
CREATE OR REPLACE FUNCTION create_membership_after_payment()
RETURNS TRIGGER AS $$
DECLARE
    item RECORD;  -- курсор
BEGIN
    -- Проверка: статус стал 'оплачено', а раньше не был
    IF (TG_OP = 'INSERT' AND NEW.status = 'оплачен') OR 
	   (TG_OP = 'UPDATE' AND NEW.status = 'оплачен' AND 
		OLD.status != 'оплачен') 
	THEN
	    -- Перебираем все элементы заказа, связанные с этим платежом
        FOR item IN
            SELECT 
                oi.membership_type_id,
                o.user_id,
                mt.days,
                mt.sessions
            FROM "OrderItem" oi
            JOIN "Order" o ON o.id = oi.order_id
            JOIN "MembershipType" mt ON mt.id = oi.membership_type_id
            WHERE o.id = NEW.order_id
        LOOP
            IF EXISTS (
                SELECT 1
                FROM "Membership"
                WHERE user_id = item.user_id
                AND membership_type_id = item.membership_type_id
            ) 
            THEN -- обновление
                UPDATE "Membership"
                SET 
                    end_date = CURRENT_DATE + INTERVAL '1 day' * item.days,
                    available_sessions = available_sessions + item.sessions,
                    order_id = NEW.order_id
                WHERE user_id = item.user_id
                AND membership_type_id = item.membership_type_id;
            ELSE
                INSERT INTO "Membership" (
                    id, user_id, membership_type_id, order_id,
                    start_date, end_date, available_sessions
                )
                VALUES (
                    gen_random_uuid(),
                    item.user_id,
                    item.membership_type_id,
                    NEW.order_id,
                    CURRENT_DATE,
                    CURRENT_DATE + INTERVAL '1 day' * item.days,
                    item.sessions
                );
            END IF;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER create_membership_after_payment_trigger
AFTER INSERT OR UPDATE ON "Payment"
FOR EACH ROW
EXECUTE FUNCTION create_membership_after_payment();


-- Функция для регистрации пользователя
CREATE OR REPLACE FUNCTION register_user(
	p_id 			UUID,
    p_email 		TEXT,
    p_phone_number 	TEXT,
    p_password 		TEXT,
    p_first_name 	TEXT,
    p_last_name 	TEXT,
    p_birth_date 	DATE,
    p_gender 		TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO "User" (
		id,
		email, 
		phone_number, 
		"password", 
		first_name, 
		last_name, 
		birth_date, 
		gender
	)
    VALUES (
		p_id,
		p_email, 
		p_phone_number,
		p_password, 
		p_first_name, 
		p_last_name, 
		p_birth_date, 
		p_gender
	);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Функция для авторизации пользователя 
CREATE OR REPLACE FUNCTION login_user(
    p_login TEXT,
    p_password TEXT
)
RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_stored_password TEXT;
BEGIN
    SELECT id, "password" INTO v_user_id, v_stored_password
    FROM "User"
    WHERE email = p_login OR phone_number = p_login;
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Неверный логин или пароль';
    END IF;
    IF p_password != v_stored_password THEN
        RAISE EXCEPTION 'Неверный логин или пароль';
    END IF;
    RETURN v_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Функция для получения текущего UUID пользователя из сессии
CREATE OR REPLACE FUNCTION current_user_id()
RETURNS UUID AS $$
BEGIN
    RETURN current_setting('myapp.current_user_id', true)::UUID;
EXCEPTION
    WHEN others THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
