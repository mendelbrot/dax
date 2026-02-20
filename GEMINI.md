## Dax Project Overview

Dax is a cross-platform application for saving and searching personal notes.

- **Frontend:** Flutter (`client-flutter/`)
- **Backend:** Supabase/PostgreSQL (`supabase/`)
- **Knowledge Base:** ('notes-dax/`)

### Flutter Frontend Guidelines (`client-flutter/`)
- NEVER run the app to verify changes (the user handles this). 
- ALWAYS check for compile errors after tasks, by running `npm run flutter:analyze`.

### Supabase/PostgreSQL Backend Guidelines (`supabase/`)
- NEVER create migration files. We use declarative schema. Edit the schemas in `supabase/schemas/` directly.
- NEVER generate migrations after editing the schemas; the user will handle migrations.
- NEVER run `supabase` CLI commands; the user will handle migration, verification, and deployment.


## Knowledge Management (`notes-dax/`)

- **`notes-dax/docs/`**: **Up-to-date Documentation.** 
- **`notes-dax/knowledge/`**: Deep-dives into specific concepts and patterns.
- **`notes-dax/assets/`**: Visual assets, including:
    - `diagrams/`: Mermaid source files (`.mmd`).
    - `images/`: Generated SVG diagrams (via `npm run mermaid`) and other images.
- **`notes-dax/dev-logs/`**: These files are for the developer and the agent to write about current thoughts and tasks. Keep it concise and informative for your future self. For example include some key files edited. Think of these logs as your memory. You write your logs in the `Agent Logs` section.

This yaml frontmatter goes in all markdown documentation:

```
---
date: <The current date as YYYY-MM-DD>
---
```

### Visual Documentation (Mermaid)
- **Workflow:** Store Mermaid source files in `notes-dax/assets/diagrams/`.
- **Generation:** Run `npm run mermaid` to generate SVG images in `notes-dax/assets/images/`.
- **Usage:** Use these diagrams in stable documentation (`notes-dax/docs/`) to illustrate system architecture and data flows.
