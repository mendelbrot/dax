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
- **`notes-dax/dev-logs/`**: These files are for the developer and the agent to write about current thoughts and tasks. 

### How to use agent logs
You append your logs to the the `Agent Logs` section (don't edit previous writing).  Currently I favor small tasks over big plans. Generally, add a sentence for each task, just as you would tell me what you did in the CLI. See your previous logs for writing style reference. If you forget and I say "log this" then just copy what you told me in our conversation into the log.

Think of these logs as a kind of memory. Read the most recent log file to get up to speed on the project.

### Visual Documentation (Mermaid)
- **Workflow:** Store Mermaid source files in `notes-dax/assets/diagrams/`.
- **Generation:** Run `npm run mermaid` to generate SVG images in `notes-dax/assets/images/`.
- **Usage:** Use these diagrams in stable documentation (`notes-dax/docs/`) to illustrate system architecture and data flows.
