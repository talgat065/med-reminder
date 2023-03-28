package main

import (
	"log"
	"os"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	tb "gopkg.in/tucnak/telebot.v2"
)

type User struct {
	ID         int64
	FirstName  string
	LastName   string
	Username   string
	TelegramID int64
}

func createUserIfNotExists(db *sqlx.DB, user *User) error {
	_, err := db.Exec(`
		INSERT INTO users (id, first_name, last_name, username, telegram_id)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (id) DO NOTHING;
	`, user.ID, user.FirstName, user.LastName, user.Username, user.TelegramID)

	return err
}

func main() {
	// Configure the Telegram bot
	b, err := tb.NewBot(tb.Settings{
		Token:  os.Getenv("TELEGRAM_TOKEN"),
		Poller: &tb.LongPoller{Timeout: 10 * time.Second},
	})
	if err != nil {
		log.Fatal(err)
	}

	// Configure the database connection
	db, err := sqlx.Connect("postgres", "user=youruser password=yourpassword dbname=yourdbname sslmode=disable")
	if err != nil {
		log.Fatalf("Failed to connect to the database: %v", err)
	}
	defer db.Close()

	// Handle the /start command
	b.Handle("/start", func(m *tb.Message) {
		user := &User{
			ID:         m.Sender.ID,
			FirstName:  m.Sender.FirstName,
			LastName:   m.Sender.LastName,
			Username:   m.Sender.Username,
			TelegramID: m.Sender.ID,
		}

		if err := createUserIfNotExists(db, user); err != nil {
			log.Printf("Error handling /start command: %v", err)
			b.Send(m.Sender, "Произошла ошибка при регистрации. Пожалуйста, попробуйте еще раз.")
		} else {
			b.Send(m.Sender, "Добро пожаловать в бот 'Дед пей таблетки'! Я помогу вам следить за приемом лекарств.")
		}
	})

	// Start the bot
	b.Start()
}
