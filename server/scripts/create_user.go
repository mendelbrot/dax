//go:build ignore

package main

import (
	"context"
	"dax/server/lib/dbl"
	"log"
)

func main() {
	client, _ := dbl.Open("postgresql://admin:secret@127.0.0.1/dax")
	defer client.Close()

	ctx := context.Background()

	if _, err := client.User.
		Create().
		SetUsername("greg").
		SetHash("hash").
		Save(ctx); err != nil {
		log.Fatalf("creating user: %v", err)
	}
}
