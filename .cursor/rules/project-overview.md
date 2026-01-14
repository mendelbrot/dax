   ---
   description: Core project overview and guidelines (always apply)
   globs: **/*  # This makes the rule apply to all files in the project
   ---

   # Project Overview and Instructions

  The objective of this project is to build a cross-platform app for saving and searching personal notes.

  This is a monorepo.

  - The Flutter frontend is in /client-flutter.
  - The Supabase backend is in /supabase.
  - Project notes are in /notes-dax.

  # Documentation

  Please write notes, guides, and documentation to the /notes-dax folder (but write plans to the .cursor/plans folder)

   Whenever you write a plan, please also create appropriate guides and documentation in /notes-dax, including mermaid diagrams where appropriate.

   Mermaid diagrams go in the /notes-dax/assets/diagrams folder. Mermaid diagram png images are generated from these using /notes-dax/mermaid.sh and go in the /notes-dax/assets/images folder. These images are then referenced in the documentation markdown files.

   # Database

   The development strategy for the database is with declarative schemas. Schemas are in /supabase/schemas. From the declarative schemas, a diff is generated with the supabase cli, to create migration files in /supabase/migrations.

   To generate a migration from schema changes, use: `npm run db:diff migration-name`

   # Testing

   Do not add tests. This is a deliberate choice for this project and may be reconsidered in the future.

   # Style

   I always prefer configuration in code. For example, the Supabase config is in /supabase/config.toml.

   For the Frontend UI design, my style preference is minimalist and clean.

