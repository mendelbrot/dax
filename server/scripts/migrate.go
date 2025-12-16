//go:build ignore

package main

import (
	"context"
	"dax/server/ent/migrate"
	"dax/server/lib/dbl"
	"log"
)

func main() {
	client, db := dbl.Open("postgresql://admin:secret@127.0.0.1/dax")
	defer client.Close()
	defer db.Close()

	ctx := context.Background()

	if _, err := db.ExecContext(
		ctx,
		"CREATE EXTENSION IF NOT EXISTS pg_trgm",
	); err != nil {
		log.Fatalf("creating pg_trgm extension: %v", err)
	}

	if err := client.Schema.Create(
		ctx,
		migrate.WithGlobalUniqueID(true),
	); err != nil {
		log.Fatalf("creating schema resources: %v", err)
	}
}
