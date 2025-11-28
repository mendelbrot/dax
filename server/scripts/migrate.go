//go:build ignore

package scripts

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

	_, err := db.
		ExecContext(ctx, "CREATE EXTENSION IF NOT EXISTS pg_trgm")
	if err != nil {
		log.Fatalf("creating pg_trgm extension: %v", err)
	}

	if err := client.Schema.Create(
		context.Background(),
		migrate.WithGlobalUniqueID(true),
	); err != nil {
		log.Fatalf("creating schema resources: %v", err)
	}
}
