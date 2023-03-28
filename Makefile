.PHONY: build serve clean help docker-build docker-run migrate

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

.PHONY: migrate
migrate:
	@echo "Running migrations..."
	@docker run --rm \
		--network=ded_pey_tabletki \
		-v $(shell pwd)/migrations:/migrations \
		-w /migrations \
		-e POSTGRES_DB=db_name \
		-e POSTGRES_USER=user \
		-e POSTGRES_PASSWORD=password \
		-e POSTGRES_HOST=postgres \
		-e POSTGRES_PORT=5432 \
		golang:1.17 sh -c 'go get -u github.com/golang-migrate/migrate/v4/cmd/migrate@latest && \
			migrate -path . -database "postgres://$$POSTGRES_USER:$$POSTGRES_PASSWORD@$$POSTGRES_HOST:$$POSTGRES_PORT/$$POSTGRES_DB?sslmode=disable" up'

migrate:
	sudo docker compose run --rm app bash -c 'migrate -database "postgres://user:password@db:5432/db_name?sslmode=disable" -path /app/migrations up'

