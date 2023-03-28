package main

import (
	"log"
	"os"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

type User struct {
	ID         int64  `db:"id"`
	TelegramID int64  `db:"telegram_id"`
	FirstName  string `db:"first_name"`
	LastName   string `db:"last_name"`
	Username   string `db:"username"`
}

var db *sqlx.DB

func main() {
	db = sqlx.MustConnect("postgres", os.Getenv("DATABASE_URL"))

	bot, err := tgbotapi.NewBotAPI("6117441992:AAF1gwFr2SuT2yHhY9ojWR73qYuuvJzSReM")
	if err != nil {
		log.Panic(err)
	}

	bot.Debug = true

	log.Printf("Authorized on account %s", bot.Self.UserName)

	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	updates, err := bot.GetUpdatesChan(u)

	for update := range updates {
		if update.Message == nil {
			continue
		}

		if update.Message.IsCommand() {
			switch update.Message.Command() {
			case "start":
				createUserIfNotExists(update.Message.From)
				msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Привет! Я бот 'Дед пей таблетки', я помогу тебе не забывать принимать таблетки вовремя.")
				msg.ReplyToMessageID = update.Message.MessageID
				bot.Send(msg)
			}
		}
	}
}

func createUserIfNotExists(from *tgbotapi.User) {
	user := User{}
	err := db.Get(&user, "SELECT * FROM users WHERE telegram_id = $1", from.ID)
	if err != nil {
		log.Printf("Creating new user: %s", from.UserName)
		_, err = db.Exec(`INSERT INTO users (telegram_id, first_name, last_name, username) VALUES ($1, $2, $3, $4)`, from.ID, from.FirstName, from.LastName, from.UserName)
		if err != nil {
			log.Printf("Error creating user: %v", err)
		}
	}
}
