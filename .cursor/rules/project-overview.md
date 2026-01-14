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

# Planning

When creating plans:
- Create plan files directly in `.cursor/plans/` directory (workspace-relative, not home directory)
- Use markdown format with YAML frontmatter for metadata
- Include status field: `pending`, `in_progress`, or `completed`
- Include created date in frontmatter
- When listing plans, only show plans from `.cursor/plans/` in this workspace
- Only show plans with status `pending` or `in_progress` unless explicitly asked for completed plans
- Update plan status to `in_progress` when starting implementation, `completed` when done
- Do NOT use the mcp_create_plan tool (it saves to home directory); create plan files directly in workspace

Mermaid diagrams go in the /notes-dax/assets/diagrams folder. Mermaid diagram svg images are generated from these using `npm run mermaid` (which runs /notes-dax/mermaid.sh) and go in the /notes-dax/assets/images folder. These images are then referenced in the documentation markdown files. Always run `npm run mermaid` after creating or updating mermaid diagram files.

# Database

The development strategy for the database is with declarative schemas. Schemas are in /supabase/schemas. From the declarative schemas, a diff is generated with the supabase cli, to create migration files in /supabase/migrations.

To generate a migration from schema changes, use: `npm run db:diff migration-name`

# Testing

Do not add tests. This is a deliberate choice for this project and may be reconsidered in the future.

# Style

I always prefer configuration in code. For example, the Supabase config is in /supabase/config.toml.

For the Frontend UI design, my style preference is minimalist and clean.

