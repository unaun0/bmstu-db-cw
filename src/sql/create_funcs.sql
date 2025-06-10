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
