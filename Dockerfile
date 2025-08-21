# ---- build stage ----
FROM golang:1.25-alpine AS build
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

# install goose in the build image
RUN go install github.com/pressly/goose/v3/cmd/goose@v3.20.0

# bring source and build the API
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/api ./cmd/api

# ---- final stage ----
FROM alpine:3.20
RUN apk --no-cache add ca-certificates curl
WORKDIR /app

# copy goose and the api binary into the runtime image
COPY --from=build /go/bin/goose /usr/local/bin/goose
COPY --from=build /app/api /app/api
# include migrations so goose can run inside the container
COPY --from=build /app/internal/db/migrations /app/internal/db/migrations

ENV PORT=8080
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD curl -fsS http://localhost:8080/health || exit 1
ENTRYPOINT ["/app/api"]
