package schema

import (
	"time"

	"entgo.io/ent"
	"entgo.io/ent/schema/edge"
	"entgo.io/ent/schema/field"
)

// Vault holds the schema definition for the Vault entity.
type Vault struct {
	ent.Schema
}

type VaultSettings map[string]string

// Fields of the Vault.
func (Vault) Fields() []ent.Field {
	return []ent.Field{
		field.String("name").
			Unique(),
		field.JSON("settings", VaultSettings{}).
			Optional(),
		field.Time("created_at").
			Default(time.Now).
			Immutable(),
	}
}

// Edges of the Vault.
func (Vault) Edges() []ent.Edge {
	return []ent.Edge{
		edge.From("users", User.Type).
			Ref("vaults"),
		edge.To("entries", Entry.Type),
	}
}
