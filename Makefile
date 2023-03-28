.PHONY: build serve clean help docker-build docker-run

.DEFAULT: help

help:
	@echo "make build                  - Собирает проект локально"
	@echo "make serve                  - Запускает сервер для разработки локально"
	@echo "make docker-build           - Собирает Docker-образ проекта"
	@echo "make docker-run             - Запускает Docker-контейнер с проектом"
	@echo "make clean                  - Удаляет сгенерированные файлы и зависимости"
	@echo "make install                - Устанавливает зависимости проекта"
	@echo "make test                   - Запускает тесты"
	@echo "make docker-compose-build   - Собирает Docker-образы для всех сервисов"
	@echo "make docker-compose-up      - Запускает все сервисы с использованием Docker Compose"
	@echo "make docker-compose-down    - Останавливает все сервисы и удаляет контейнеры, сети, тома и образы, определенные в docker-compose.yml"

# Замените my_project на имя вашего проекта или путь к исполняемому файлу.
build:
	go build -o my_project

serve:
	go run my_project

docker-build:
	docker build -t my_project:latest .

docker-run:
	docker run -p 8080:8080 --env-file .env --name my_project_container my_project:latest

clean:
	go clean
	rm -rf vendor

install:
	go mod tidy
	go mod vendor

test:
	go test -v ./...

docker-compose-build:
	sudo docker compose build

docker-compose-up:
	sudo docker compose up -d

docker-compose-down:
	sudo docker compose down --remove-orphans