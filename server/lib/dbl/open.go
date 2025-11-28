package dbl

import (
	"database/sql"
	"dax/server/ent"
	"log"

	"entgo.io/ent/dialect"
	entsql "entgo.io/ent/dialect/sql"
	_ "github.com/jackc/pgx/v5/stdlib"
)

func Open(databaseUrl string) (*ent.Client, *sql.DB) {
	db, err := sql.Open("pgx", databaseUrl)
	if err != nil {
		log.Fatalf("opening the database: %v", err)
	}
	drv := entsql.OpenDB(dialect.Postgres, db)
	return ent.NewClient(ent.Driver(drv)), db
}
