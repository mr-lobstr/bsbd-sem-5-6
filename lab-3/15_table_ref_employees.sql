SET ROLE app_owner;

CREATE TABLE app.employees(
    id SERIAL PRIMARY KEY,
    surname VARCHAR(30) NOT NULL,
    name VARCHAR(30) NOT NULL,
    middle_name VARCHAR(30),
    postal_object_id INTEGER NOT NULL
        REFERENCES ref.postal_objects(id) ON DELETE RESTRICT,
    position VARCHAR(50) NOT NULL,
    business_phone VARCHAR(12)
);

INSERT INTO app.employees(
    surname,
    name,
    middle_name,
    postal_object_id,
    position,
    business_phone
) VALUES
    ('Иванов', 'Иван', 'Иванович', 1, 'Начальник отделения', '84951234567'),
    ('Петрова', 'Мария', 'Сергеевна', 2, 'Почтальон', '84951234568'),
    ('Сидоров', 'Алексей', 'Петрович', 3, 'Оператор', '84951234569'),
    ('Козлова', 'Елена', 'Владимировна', 4, 'Бухгалтер', '84951234570'),
    ('Морозов', 'Дмитрий', 'Александрович', 5, 'Водитель', '84951234571'),
    ('Волкова', 'Наталья', 'Игоревна', 6, 'Сортировщик', '84951234572'),
    ('Соколов', 'Павел', 'Андреевич', 7, 'Заместитель начальника', '84951234573'),
    ('Михайлова', 'Анна', 'Дмитриевна', 8, 'Оператор', '84951234574'),
    ('Новиков', 'Сергей', 'Алексеевич', 9, 'Почтальон', '84951234575'),
    ('Лебедева', 'Ольга', 'Николаевна', 10, 'Кассир', '84951234576');

RESET ROLE;