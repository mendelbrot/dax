//go:build ignore

package main

import (
    "log"

    "entgo.io/ent/entc"
    "entgo.io/ent/entc/gen"
    "entgo.io/contrib/entgql"
)

func main() {
    ex, err := entgql.NewExtension(
        entgql.WithSchemaGenerator(),
        entgql.WithWhereInputs(true),
        entgql.WithConfigPath("gqlgen.yml"),
        entgql.WithSchemaPath("ent.graphql"),
    )
    if err != nil {
        log.Fatalf("creating entgql extension: %v", err)
    }
    opts := []entc.Option{
        entc.Extensions(ex),
    }
    if err := entc.Generate("./ent/schema", &gen.Config{}, opts...); err != nil {
        log.Fatalf("running ent codegen: %v", err)
    }
}