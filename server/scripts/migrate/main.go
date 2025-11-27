package main

import (
	"context"
	"database/sql"
	"log"

	"dax/server/ent"
	"dax/server/ent/migrate"

    _ "github.com/jackc/pgx/v5/stdlib"

	"entgo.io/ent/dialect"
	entsql "entgo.io/ent/dialect/sql"
)

func Open(databaseUrl string) (*ent.Client, *sql.DB) {
	db, err := sql.Open("pgx", databaseUrl)
	if err != nil {
		log.Fatalf("opening the database: %v", err)
	}
	drv := entsql.OpenDB(dialect.Postgres, db)
	return ent.NewClient(ent.Driver(drv)), db
}

func main() {
	client, db := Open("postgresql://admin:secret@127.0.0.1/dax")
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

	log.Println("migration complete.")
}
