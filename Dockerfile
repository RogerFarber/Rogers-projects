FROM golang:1.25 AS build
ENV GOTOOLCHAIN=auto
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /api ./cmd/api
FROM gcr.io/distroless/base-debian12
COPY --from=build /api /api
EXPOSE 8080
ENTRYPOINT ["/api"]
