INSERT INTO "User" 
(id, first_name, last_name, "password", email, phone_number, birth_date, gender)
VALUES 
('6a4c2e33-3620-41f8-9ccb-cccdac1cbc8f', 'Иван', 'Иванов', 'A', 'iviv@m.ru', '+71234567890', '1990-01-01', 'мужской'),
('c221d3fb-fe64-4592-a9e7-2da7ccfb2056', 'Анна', 'Перова', 'B', 'mapa@m.ru', '+71234567891', '2005-12-15', 'женский'),
('aba9dde6-6438-41c2-a7c6-84171483d174', 'Петр', 'Петров', 'C', 'pepe@m.ru', '+71234567491', '2001-05-27', 'мужской');
SELECT * FROM "User";

INSERT INTO "Trainer" (id, user_id, description)
VALUES ('c9911674-7b6b-404b-be55-cce491dfe6b4', '6a4c2e33-3620-41f8-9ccb-cccdac1cbc8f', 'Тренер Иван Иванов.');
SELECT * FROM "Trainer";

INSERT INTO "Specialization" (id, name)
VALUES ('8402d7cf-508f-4882-9941-3f0ca1a114d4', 'Специализация 1');
SELECT * FROM "Specialization";

INSERT INTO "TrainerSpecialization" (trainer_id, specialization_id, years)
VALUES ('c9911674-7b6b-404b-be55-cce491dfe6b4', '8402d7cf-508f-4882-9941-3f0ca1a114d4', 10);
SELECT * FROM "TrainerSpecialization";

INSERT INTO "MembershipType" (id, name, days, sessions)
VALUES ('d1011674-7b6b-404b-be55-cce491dfeff4', 'Тип абонемента 1', 30, 4);
SELECT * FROM "MembershipType";

INSERT INTO "TrainingRoom" (id, name, capacity)
VALUES ('aaa12674-7b6b-404b-be55-cce491dfeff4', 'Зал 1', 1);
SELECT * FROM "TrainingRoom";

INSERT INTO "Order" (id, user_id, date, total_price)
VALUES ('110c07ff-a6c5-4799-9ac8-61da6f572e25', 'c221d3fb-fe64-4592-a9e7-2da7ccfb2056', NOW(), 0.00),
	   ('d20d4d35-ecf7-40b5-9238-f41c9a005911', 'aba9dde6-6438-41c2-a7c6-84171483d174', NOW(), 0.00);
SELECT * FROM "Order";

INSERT INTO "OrderItem" (order_id, membership_type_id)
VALUES ('110c07ff-a6c5-4799-9ac8-61da6f572e25', 'd1011674-7b6b-404b-be55-cce491dfeff4'),
	   ('d20d4d35-ecf7-40b5-9238-f41c9a005911', 'd1011674-7b6b-404b-be55-cce491dfeff4');
SELECT * FROM "OrderItem";

INSERT INTO "Payment" (order_id, transaction_id)
VALUES ('110c07ff-a6c5-4799-9ac8-61da6f572e25', 'transaction 1');
SELECT * FROM "Payment";

INSERT INTO "Training" (trainer_id, specialization_id, room_id, date)
VALUES (
	'c9911674-7b6b-404b-be55-cce491dfe6b4', 
	'8402d7cf-508f-4882-9941-3f0ca1a114d4',
	'aaa12674-7b6b-404b-be55-cce491dfeff4', 
	'2025-04-09 10:00:00'
);
SELECT * FROM "Training";

    -- Вставляем посещение с генерированным UUID
    INSERT INTO "Attendance" 
        (id, user_id, training_id, status)
    VALUES 
        (v_att1, v_usr1, v_trg1, 'посетил'),
        (v_att2, v_usr2, v_trg1, 'отсутствовал');
END;
$$;

delete from "User" where first_name = 'Обновлено';