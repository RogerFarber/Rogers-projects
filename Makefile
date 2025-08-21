APP=api
build: ; go build -o bin/$(APP) ./cmd/api
run: ; go run ./cmd/api
test: ; ginkgo -r -p
up: ; docker compose up --build -d
down: ; docker compose down -v
