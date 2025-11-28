package main

import (
	"dax/server/lib/dbl"
	"log"
	"net/http"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/playground"
)

func main() {
	client, _ := dbl.Open("postgresql://admin:secret@127.0.0.1/dax")

	// Configure the server and start listening on :8081.
	srv := handler.NewDefaultServer(NewSchema(client))
	http.Handle("/",
		playground.Handler("Dax", "/query"),
	)
	http.Handle("/query", srv)
	log.Println("listening on :8081")
	if err := http.ListenAndServe(":8081", nil); err != nil {
		log.Fatal("http server terminated", err)
	}
}
