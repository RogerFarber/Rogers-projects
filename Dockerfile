# ---- build stage ----
FROM golang:1.25-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# tools
RUN go install github.com/pressly/goose/v3/cmd/goose@v3.20.0
# binaries
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/api    ./cmd/api
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/worker ./cmd/worker

# ---- API runtime ----
FROM alpine:3.20 AS api
RUN apk --no-cache add ca-certificates curl
WORKDIR /app
COPY --from=build /out/api /app/api
COPY --from=build /go/bin/goose /usr/local/bin/goose
COPY internal/db/migrations /app/internal/db/migrations
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD curl -fsS http://localhost:8080/health || exit 1
ENTRYPOINT ["/app/api"]

# ---- Worker runtime ----
FROM alpine:3.20 AS worker
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=build /out/worker /app/worker
ENTRYPOINT ["/app/worker"]
