DROP POLICY IF EXISTS personal_client_trainer_user_policy ON "User";
DROP POLICY IF EXISTS public_client_trainer_user_policy ON "User";
DROP POLICY IF EXISTS public_client_trainer_trainer_policy ON "Trainer";
DROP POLICY IF EXISTS personal_trainer_trainer_policy ON "Trainer";
DROP POLICY IF EXISTS client_trainer_membership_policy ON "Membership";
DROP POLICY IF EXISTS client_trainer_order_policy ON "Order";
DROP POLICY IF EXISTS client_trainer_payment_policy ON "Payment";
DROP POLICY IF EXISTS client_trainer_attendance_policy ON "Attendance";
DROP POLICY IF EXISTS client_trainer_order_item_policy ON "OrderItem";
DROP POLICY IF EXISTS client_training_select_policy ON "Training";
DROP POLICY IF EXISTS trainer_membership_policy ON "Membership";
DROP POLICY IF EXISTS trainer_attendance_policy ON "Attendance";
DROP POLICY IF EXISTS trainer_training_update_policy ON "Training";
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM client;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM trainer;
DROP ROLE IF EXISTS trainer;
DROP ROLE IF EXISTS client;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM guest;
DROP ROLE IF EXISTS guest;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM admin;
DROP ROLE IF EXISTS admin;

CREATE ROLE guest WITH LOGIN;
GRANT EXECUTE ON FUNCTION register_user(
	UUID, TEXT, TEXT, TEXT, TEXT, TEXT, DATE, TEXT
) TO guest;
GRANT EXECUTE ON FUNCTION login_user(TEXT, TEXT) TO guest;

CREATE ROLE client WITH
    LOGIN
    PASSWORD 'client';
CREATE ROLE trainer WITH
    LOGIN
    PASSWORD 'trainer';
GRANT client TO trainer;
GRANT ALL ON "User" TO client;
GRANT ALL ON "User" TO trainer;
ALTER TABLE "User" ENABLE ROW LEVEL SECURITY;
CREATE POLICY personal_client_trainer_user_policy
    ON "User"
    FOR ALL
    TO client, trainer
    USING (id = current_user_id());
CREATE POLICY public_client_trainer_user_policy
    ON "User"
    FOR SELECT
    TO client, trainer
    USING (TRUE);

GRANT ALL ON "Trainer" TO client;
GRANT ALL ON "Trainer" TO trainer;
ALTER TABLE "Trainer" ENABLE ROW LEVEL SECURITY;
CREATE POLICY public_client_trainer_trainer_policy
    ON "Trainer"
    FOR SELECT
    TO client, trainer
    USING (TRUE);
CREATE POLICY personal_trainer_trainer_policy
    ON "Trainer"
    FOR ALL
    TO trainer
    USING (user_id = current_user_id());

GRANT ALL ON "Membership" TO client;
GRANT ALL ON "Membership" TO trainer;
ALTER TABLE "Membership" ENABLE ROW LEVEL SECURITY;
CREATE POLICY client_trainer_membership_policy
    ON "Membership"
    FOR ALL
    TO client, trainer
    USING (user_id = current_user_id());
CREATE POLICY trainer_membership_policy
    ON "Membership"
    FOR SELECT
    TO trainer
    USING (TRUE);

GRANT ALL ON "Payment" TO client;
GRANT ALL ON "Payment" TO trainer;
ALTER TABLE "Payment" ENABLE ROW LEVEL SECURITY;
CREATE POLICY client_trainer_payment_policy
    ON "Payment"
    FOR ALL
    TO client, trainer
    USING (user_id = current_user_id());

GRANT ALL ON "Attendance" TO client;
GRANT ALL ON "Attendance" TO trainer;
ALTER TABLE "Attendance" ENABLE ROW LEVEL SECURITY;
CREATE POLICY client_trainer_attendance_policy
    ON "Attendance"
    FOR ALL
    TO client, trainer
    USING (
		membership_id IN (
			SELECT id 
			FROM "Membership"
			WHERE user_id = current_user_id()
		)
	);
CREATE POLICY trainer_attendance_policy 
    ON "Attendance"
    FOR ALL
    TO trainer
    USING (
        training_id IN (
            SELECT id 
            FROM "Training"
            WHERE trainer_id = (
				SELECT id
				FROM "Trainer"
				WHERE user_id = current_user_id()
			)
        )
    );

GRANT SELECT ON "Specialization" TO client;
GRANT SELECT ON "Specialization" TO trainer;

GRANT SELECT ON "TrainerSpecialization" TO client;
GRANT SELECT ON "TrainerSpecialization" TO trainer;

GRANT ALL ON "Training" TO trainer;
GRANT ALL ON "Training" TO client;
ALTER TABLE "Training" ENABLE ROW LEVEL SECURITY;
CREATE POLICY client_training_select_policy
    ON "Training"
    FOR SELECT
    TO client, trainer
    USING (TRUE);
CREATE POLICY trainer_training_update_policy
    ON "Training"
    FOR ALL
    TO trainer
    USING (
        trainer_id = (
			SELECT id 
			FROM "Trainer"
			WHERE user_id = current_user_id()
		)
    );

GRANT SELECT ON "MembershipType" TO client;
GRANT SELECT ON "MembershipType" TO trainer;

GRANT SELECT ON "TrainingRoom" TO client;
GRANT SELECT ON "TrainingRoom" TO trainer;


CREATE ROLE admin WITH
    LOGIN   		 	-- Роль может использоваться для входа в PostgreSQL (становится полноценным пользователем)
    PASSWORD 'admin' 	-- Пароль для входа
    SUPERUSER        	-- Даёт полный доступ ко всем возможностям PostgreSQL
    BYPASSRLS;         	-- Разрешает игнорировать политики RLS (Row-Level Security)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
