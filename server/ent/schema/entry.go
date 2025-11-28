package schema

import (
	"dax/server/lib/types"
	"time"

	"entgo.io/contrib/entgql"
	"entgo.io/ent"
	"entgo.io/ent/dialect"
	"entgo.io/ent/dialect/entsql"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/edge"
	"entgo.io/ent/schema/field"
	"entgo.io/ent/schema/index"
)

// Entry holds the schema definition for the Entry entity.
type Entry struct {
	ent.Schema
}

// Fields of the Entry.
func (Entry) Fields() []ent.Field {
	return []ent.Field{
		field.String("heading").
			Optional(),
		field.Text("body").
			Optional(),
		field.JSON("attributes", types.JSON{}).
			Optional().
			Annotations(
				entgql.Type("JSON"),
			),
		field.Time("created_at").
			Default(time.Now).
			Immutable(),
		field.Time("updated_at").
			UpdateDefault(time.Now),
	}
}

// Edges of the Entry.
func (Entry) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("vault", Vault.Type).
			Ref("entries").
			Unique(),
	}
}

// Indexes / GINs
func (Entry) Indexes() []ent.Index {
	return []ent.Index{
		index.Fields("heading").
			Annotations(
				entsql.IndexTypes(map[string]string{
					dialect.Postgres: "GIN",
				}),
				entsql.OpClass("gin_trgm_ops"),
			),
		index.Fields("created_at").
			Annotations(entsql.Desc()),
		index.Fields("updated_at").
			Annotations(entsql.Desc()),
	}
}

func (Entry) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entgql.QueryField(),
		entgql.Mutations(
			entgql.MutationCreate(),
			entgql.MutationUpdate(),
		),
	}
}
