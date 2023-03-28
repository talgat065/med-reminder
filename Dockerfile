# Build stage
FROM golang:1.17 as builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o main

# Runtime stage
FROM gcr.io/distroless/base-debian11

WORKDIR /app

COPY --from=builder /app/main /app/main

EXPOSE 9000

CMD ["/app/main"]
