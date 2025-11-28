package schema

import (
	"dax/server/lib/types"
	"time"

	"entgo.io/contrib/entgql"
	"entgo.io/ent"
	"entgo.io/ent/schema"
	"entgo.io/ent/schema/edge"
	"entgo.io/ent/schema/field"
)

// User holds the schema definition for the User entity.
type User struct {
	ent.Schema
}

// Fields of the User.
func (User) Fields() []ent.Field {
	return []ent.Field{
		field.String("username").
			Unique(),
		field.String("hash").Sensitive(),
		field.JSON("settings", types.JSON{}).
			Optional().
			Annotations(
				entgql.Type("JSON"),
			),
		field.Time("created_at").
			Default(time.Now).
			Immutable(),
		field.Time("active_at"),
	}
}

// Edges of the User.
func (User) Edges() []ent.Edge {
	return []ent.Edge{
		edge.To("vaults", Vault.Type),
	}
}

func (User) Annotations() []schema.Annotation {
	return []schema.Annotation{
		entgql.QueryField(),
		entgql.Mutations(
			entgql.MutationUpdate(),
		),
	}
}