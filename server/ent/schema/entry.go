package schema

import (
	"time"

	"entgo.io/ent"
	"entgo.io/ent/schema/edge"
	"entgo.io/ent/schema/field"
	_ "entgo.io/ent/schema/index"
)

// Entry holds the schema definition for the Entry entity.
type Entry struct {
	ent.Schema
}

type EntryAttrs map[string]string

// Fields of the Entry.
func (Entry) Fields() []ent.Field {
	return []ent.Field{
		field.String("heading").
			Optional(),
		field.Text("body").
			Optional(),
		field.JSON("attributes", EntryAttrs{}).Optional(),
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
    return nil
}