DELETE FROM "Attendance";
DELETE FROM "Payment";
DELETE FROM "Membership";
DELETE FROM "MembershipType";
DELETE FROM "TrainingRoom";
DELETE FROM "Training";
DELETE FROM "TrainerSpecialization";
DELETE FROM "Trainer";
DELETE FROM "Specialization";
DELETE FROM "User";

INSERT INTO "User" (id, email, phone_number, "password", first_name, last_name, gender, birth_date, "role") VALUES
('22222222-2222-2222-2222-222222222203', 'ekaterina@example.com', '+79991112232', '$2b$12$q28Pz41Vn2pJZZ9pFr/DA.nsqVMfOob3IeJ8QbBWX3W541upIi1bW', 'Екатерина', 'Иванова', 'женский', '2002-11-17', 'тренер'),
('33333333-3333-3333-3333-333333333332', 'yana@example.com', '+79991112231', '$2b$12$H2Ex.sTPKf/6vGyasFnlgeZrRFHaVRvZhZA9SzLANxb5r0DY6.fui', 'Яна', 'Цховребова', 'женский', '2001-11-17', 'администратор'),
('11111111-1111-1111-1111-111111111113', 'ivan@example.com', '+79991112233', '$2b$12$DjSq8k3ZK8k86/rBcvNdwuPWTJrYgWA.fY5kZ2wMc9KrMNVzx1UTG', 'Иван', 'Иванов', 'мужской', '1999-11-17', 'клиент');

INSERT INTO "Specialization" (id, name) VALUES
    ('a1d1c888-19b0-4f9a-8c1c-1b7f7c0a0e11', 'Силовые тренировки'),
    ('b2e2d999-20c1-4a0b-9d2d-2c8f8d1b1f22', 'Кардио'),
    ('c3f3eaaa-31d2-4b1c-8e3e-3d9f9e2c2f33', 'Функциональный тренинг');

INSERT INTO "Trainer" (id, user_id, description) VALUES (
    'c2077813-0503-4c4f-b58b-e88fb541602f',
    '22222222-2222-2222-2222-222222222203',
    'Опытный тренер.'
);

INSERT INTO "TrainerSpecialization" (id, trainer_id, specialization_id, years) VALUES
    ('11111111-aaaa-bbbb-cccc-000000000001', 'c2077813-0503-4c4f-b58b-e88fb541602f', 'a1d1c888-19b0-4f9a-8c1c-1b7f7c0a0e11', 5),
    ('11111111-aaaa-bbbb-cccc-000000000002', 'c2077813-0503-4c4f-b58b-e88fb541602f', 'b2e2d999-20c1-4a0b-9d2d-2c8f8d1b1f22', 3);

INSERT INTO "TrainingRoom" (id, name, capacity) VALUES
    ('a1111111-1111-1111-1111-111111111111', 'Зал 1', 1),
    ('b2222222-2222-2222-2222-222222222222', 'Зал 2', 2),
    ('c3333333-3333-3333-3333-333333333333', 'Зал 3', 3);

INSERT INTO "MembershipType" (id, name, price, sessions, days) VALUES
    ('d4444444-4444-4444-4444-444444444444', 'Стандартный', 5000, 12, 30);

INSERT INTO "Training" (id, specialization_id, room_id, trainer_id, "date") VALUES
    ('aaaaaaa1-1111-1111-1111-111111111111', 'b2e2d999-20c1-4a0b-9d2d-2c8f8d1b1f22', 'a1111111-1111-1111-1111-111111111111', 'c2077813-0503-4c4f-b58b-e88fb541602f', CURRENT_DATE + INTERVAL '1 day' + INTERVAL '18 hour 30 minute'),
    ('aaaaaaa2-2222-2222-2222-222222222222', 'b2e2d999-20c1-4a0b-9d2d-2c8f8d1b1f22', 'b2222222-2222-2222-2222-222222222222', 'c2077813-0503-4c4f-b58b-e88fb541602f', CURRENT_DATE + INTERVAL '2 day' + INTERVAL '18 hour 30 minute'),
	('aaaaaaa2-2222-2222-2222-222222222223', 'b2e2d999-20c1-4a0b-9d2d-2c8f8d1b1f22', 'c3333333-3333-3333-3333-333333333333', 'c2077813-0503-4c4f-b58b-e88fb541602f', CURRENT_DATE + INTERVAL '3 day' + INTERVAL '18 hour 30 minute');

INSERT INTO "Membership" (id, user_id, membership_type_id, start_date, end_date, available_sessions) VALUES
    ('a1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111113', 'd4444444-4444-4444-4444-444444444444', CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 12),
    ('b2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222203', 'd4444444-4444-4444-4444-444444444444', CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 12),
    ('c3333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333332', 'd4444444-4444-4444-4444-444444444444', CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 12);

INSERT INTO "Payment" (id, membership_id, transaction_id, "date", "method", gateway, status) VALUES
('f1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'tx10001', CURRENT_TIMESTAMP, 'наличные', 'A', 'оплачен'),
('f2222222-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'tx10002', CURRENT_TIMESTAMP, 'наличные', 'B', 'оплачен'),
('f3333333-3333-3333-3333-333333333333', 'c3333333-3333-3333-3333-333333333333', 'tx10003', CURRENT_TIMESTAMP, 'наличные', 'C', 'оплачен');


INSERT INTO "Attendance" (id, membership_id, training_id, status) VALUES
(gen_random_uuid(), 'a1111111-1111-1111-1111-111111111111', 'aaaaaaa1-1111-1111-1111-111111111111', 'ожидает'),
(gen_random_uuid(), 'a1111111-1111-1111-1111-111111111111', 'aaaaaaa2-2222-2222-2222-222222222222', 'ожидает'),
(gen_random_uuid(), 'a1111111-1111-1111-1111-111111111111', 'aaaaaaa2-2222-2222-2222-222222222223', 'ожидает'),
(gen_random_uuid(), 'b2222222-2222-2222-2222-222222222222', 'aaaaaaa2-2222-2222-2222-222222222222', 'ожидает'),
(gen_random_uuid(), 'b2222222-2222-2222-2222-222222222222', 'aaaaaaa2-2222-2222-2222-222222222223', 'ожидает'),
(gen_random_uuid(), 'c3333333-3333-3333-3333-333333333333', 'aaaaaaa1-1111-1111-1111-111111111111', 'ожидает'),
(gen_random_uuid(), 'c3333333-3333-3333-3333-333333333333', 'aaaaaaa2-2222-2222-2222-222222222222', 'ожидает'),
(gen_random_uuid(), 'c3333333-3333-3333-3333-333333333333', 'aaaaaaa2-2222-2222-2222-222222222223', 'ожидает');
