package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/RogerFarber/eventsapi/internal/db"
	"github.com/RogerFarber/eventsapi/pkg/httpx"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	if _, err := db.Connect(context.Background()); err != nil {
		log.Fatal(err)
	}

	r := chi.NewRouter()
	r.Use(middleware.RequestID, middleware.Logger, middleware.Recoverer, httpx.JSONContentType())

	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		httpx.WriteJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	srv := &http.Server{Addr: ":" + port, Handler: r, ReadHeaderTimeout: 5 * time.Second}
	log.Printf("listening on :%s", port)
	log.Fatal(srv.ListenAndServe())
}
