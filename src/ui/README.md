# Мобильное приложение для управления фитнес-клубом

**⚠️ Разаботана только серверная часть приложения ⚠️**

## Идея проекта

Приложение предназначено для управления фитнес-клубом, включая регистрацию пользователей, покупку абонементов, расписание тренировок и учет посещений. Оно позволяет клиентам бронировать тренировки, а тренерам и администраторам управлять расписанием и пользователями.

## Предметная область

Фитнес-индустрия, автоматизация работы фитнес-клубов, управление тренировками и абонементами.

## Актуальность и целесообразность

В современном мире цифровые решения играют ключевую роль в организации услуг. Большинство фитнес-клубов сталкиваются с проблемами учета клиентов, продаж абонементов и расписания тренировок. Приложение для управления фитнес-клубом решает эти задачи, автоматизируя процессы и повышая удобство как для клиентов, так и для сотрудников клуба.

Основные преимущества:
* упрощение записи на тренировки;
* автоматизация покупки абонементов;
* управление расписанием тренировок;
* улучшение взаимодействия между клиентами и тренерами;
* Аналитика и учет посещений.

## Анализ аналогичных решений

| Приложение | Функциональность | Интеграция с клубами | Гибкость расписания | Платежи | Дополнительные функции |
|:-:|:-:|:-:|:-:|:-:|:-:|
| **Mindbody**   | Запись на тренировки, управление клиентами | Поддерживает разные клубы | Гибкое расписание | Поддержка платежей | - |
| **Fitternity** | Разовые посещения, поиск тренировок | Поддерживает разные клубы | Только разовые тренировки | Поддержка платежей | -|
| **MyFitnessPal** | Трекер питания и тренировок | - | - | - | Аналитика, калории |

## Пользователи

**Гость**: анонимный пользователь.

**Клиент**: записывается на тренировки, покупает абонементы.

**Тренер**: создает расписание, проводит тренировки.

**Администратор**: управляет пользователями, абонементами и расписанием.

## Use-Case

Диаграмма вариантов использования демонстрирует взаимодействие пользователей с системой.

![Use-Case](inc/diag/svg/use-case.svg)

## ER (в нотации Чена)

Диаграмма сущностей и связей (в нотации Чена) отражает сущности и связи между ними.

![ER](inc/diag/svg/er-chen.svg)

## Пользовательские сценарии

### Регистрация

**Акторы:** гость, система.

**Предусловие:** гость не зарегистрирован.

#### Основной поток

1. Гость открывает приложение.

2. Система отображает экран входа с возможностью регистрации.

3. Гость нажимает «Зарегистрироваться».

4. Система предлагает заполнить форму с пользовательскими данными. 

5. Гость заполняет поля и отправляет форму.

6. Система проверяет корректность данных.

7. Если данные корректны, система создаёт пользователя в базе данных.

8. Система уведомляет об успешной регистрации. 

#### Альтернативные потоки

- **6а.** Если email или номер телефона уже используются – система показывает ошибку.

- **6б.** Если данные некорректны – система запрашивает исправления. 

---

### Аутентификация

**Акторы:** гость, система.

**Предусловие:** гость зарегистрирован.

#### Основной поток

1. Гость открывает приложение.

2. Система отображает экран входа.

3. Пользователь вводит email / номер телефона и пароль.

4. Система проверяет учетные данные в базе данных.

5. Если данные верны, система авторизует пользователя и перенаправляет в личный кабинет.

#### Альтернативные потоки

- **4а.** Если email / номер телефона не найдены – система показывает ошибку.

- **4б.** Если пароль неверный – система показывает ошибку.

---

### Покупка абонемента

**Акторы:** пользователь, система.

**Предусловие:** пользователь авторизован.

#### Основной поток

1. Пользователь открывает раздел «Абонементы».

2. Система отображает список доступных абонементов.

3. Пользователь выбирает абонемент и нажимает «Купить».

4. Система обрабатывает запрос и предлагает оплатить услугу.

5. Пользователь подтверждает оплату.

6. Система обрабатывает данные об оплате.

7. При успешной оплате система добавляет абонемент в профиль пользователя.

8. Система уведомляет пользователя об успешной покупке.

#### Альтернативные потоки

- **6а.** Если оплата не прошла – система уведомляет пользователя и предлагает попробовать снова.

--- 

### Запись на тренировку

**Акторы:** пользователь, система.

**Предусловие:** у пользователя есть действующий абонемент.  

#### Основной поток

1. Пользователь открывает раздел «Расписание тренировок».

2. Система отображает список доступных тренировок.

3. Пользователь выбирает тренировку и нажимает «Записаться».

4. Система проверяет наличие свободных мест.

5. Если место доступно, система записывает пользователя и обновляет его статус в базе данных.

6. Система уведомляет пользователя об успешной записи.

#### Альтернативные потоки

- **4а.** Если мест нет – система показывает сообщение и предлагает выбрать другую тренировку.

- **4б.** Если у пользователя нет подходящего абонемента – система предлагает его приобрести.

---

### Просмотр и управление расписанием тренировок

**Акторы:** тренер, администратор, система.

**Предусловие:** тренер / администратор авторизован.  

#### Основной поток

1. Тренер / администратор открывает раздел «Расписание».

2. Система отображает календарь с тренировками.

3. Тренер / администратор может:  
   - добавить тренировку в расписание,
   - изменить время тренировки,
   - изменить зал для проведения тренировки,
   - отменить тренировку.

4. Система обновляет данные в базе данных и уведомляет записанных пользователей.

#### Альтернативные потоки

- **3а.** Если изменение невозможно – система предупреждает тренера / администратора.

- **3б.** Если тренировка уже началась – изменения запрещены (кроме отмены, доступной только администратору).

--- 

### Изменение данных пользователя

**Акторы:** клиент, тренер, администратор, система.

**Предусловие:** пользователь авторизован.

#### Основной поток

1. Клиент / тренер / администратор открывает свой профиль.

2. Система отображает текущие данные.

3. Клиент / тренер / администратор редактирует информацию (например, имя, телефон).  

4. Система проверяет корректность данных. 

5. Если данные верны, система сохраняет изменения.

#### Альтернативные потоки

- **1а.** Администратор открывает профиль другого пользователя (может изменять данные профиля любого пользователя).

- **4a.** Если введенные данные некорректны или их невозможно изменить – система показывает ошибку.

---

### Изменение данных о посещаемости тренировки

**Акторы:** тренер, администратор, cистема.

**Предусловие:** тренировка завершена.

#### Основной поток

1. Тренер / администратор открывает список участников. 

2. Система отображает записанных пользователей.

3. Тренер / администратор отмечает всех, кто присутствовал.

4. Система сохраняет посещаемость в базе данных. 

#### Альтернативные потоки

- **3а.** Если тренировка отменена – система закрывает возможность редактирования.

---

## Формализация ключевых бизнес-процессов

BPMN-диаграмма бизнес-процессов отражает ключевые этапы взаимодействия пользователей и системы, показывая последовательность действий, принимаемые решения и работу с данными.

![Процесс входа и регистрации](./inc/diag/svg/bpmn-auth.svg)

![Процесс приобретения абонемента](./inc/diag/svg/bpmn-get-membership.svg)

![Процесс записи на тренировку](./inc/diag/svg/bpmn-get-training.svg)

## Тип приложения и технологический стек

**Тип приложения:** мобильное (iOS)

### Технологический стек:

#### Клиентская часть

* **Язык программирования:** Swift
* **Фреймворк:** UIKit

#### Серверная часть

* **Фреймворк:** Vapor (Swift)
* **ORM:** Fluent
* **Базы данных:** PostgreSQL, Redis (Кэш)

## Верхнеуровневое разбиение на компоненты

![Верхнеуровневое разбиение на компоненты](./inc/diag/svg/high-arch.svg)

## UML-диаграммы классов компонентов доступа к данным и безнес-логики

![Верхнеуровневое разбиение на компоненты](./inc/diag/svg/uml.svg)