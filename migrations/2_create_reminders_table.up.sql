CREATE TABLE reminders (
                           id SERIAL PRIMARY KEY,
                           user_id INTEGER REFERENCES users (id),
                           medicine_name TEXT,
                           days INTEGER,
                           times_per_day INTEGER,
                           reminder_time TEXT
);
