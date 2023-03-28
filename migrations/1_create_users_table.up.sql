CREATE TABLE users (
                       id SERIAL PRIMARY KEY,
                       telegram_id BIGINT UNIQUE,
                       username TEXT,
                       first_name TEXT,
                       last_name TEXT
);
