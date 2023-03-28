# Build stage
FROM golang:1.17 as builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o main
RUN go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Runtime stage
FROM debian:buster-slim

# Install bash and ca-certificates
RUN apt-get update && apt-get install -y bash ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/main /app/main
COPY --from=builder /go/bin/migrate /usr/local/bin/migrate

EXPOSE 9000

CMD ["/app/main"]
