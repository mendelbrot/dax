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


## User / AI assistant interaction cycle

1. **Ask**
2. **Learn**
3. **Plan**
4. **Act**
5. **Document**


## Core Behavioral Rules

- **Planning First:** Always prioritize planning, understanding, and shared decision-making. Coding is the final step after a plan is agreed upon.
- **Consultative Approach:** Ask clarifying questions and discuss trade-offs before proceeding with significant changes.
- **Prompt Modifiers:**
  - `ask:` Answer the question without performing file operations or actions.
  - `log:` Follow the steps in the DevLog Convention.
  - `plan:` Initiate a structured planning session. Create a new plan in `notes-dax/plans/YYYY-MM-DD-[topic].md`. Remember to put the date in the yaml frontmatter for all markdown files as specified under the 'Knowledge Management' section.


## Knowledge Management (`notes-dax/`)

We use the `notes-dax` folder to manage project state and knowledge. 
*Note: Files within `notes-dax/archive/` may contain outdated information and should be referenced with caution.*

- **`notes-dax/plans/`**: Plans.
- **`notes-dax/docs/`**: **Up-to-date Documentation.** 
- **`notes-dax/knowledge/`**: Deep-dives into specific concepts and patterns.
- **`notes-dax/assets/`**: Visual assets, including:
    - `diagrams/`: Mermaid source files (`.mmd`).
    - `images/`: Generated SVG diagrams (via `npm run mermaid`) and other images.
- **`notes-dax/dev-logs/`**: Brain dumps.

This yaml frontmatter goes in all markdown documentation, guides, plans, and logs:

```
---
date: <The current date as YYYY-MM-DD>
---
```

### Visual Documentation (Mermaid)
- **Workflow:** Store Mermaid source files in `notes-dax/assets/diagrams/`.
- **Generation:** Run `npm run mermaid` to generate SVG images in `notes-dax/assets/images/`.
- **Usage:** Use these diagrams in stable documentation (`notes-dax/docs/`) to illustrate system architecture and data flows.

### DevLog Convention
- **Trigger:** The user starts a prompt with **"log:"**.
- **Action:** Create a new entry in `notes-dax/dev-logs/YYYY-MM-DD-[topic].md` containing the raw input and AI point form breakdown. After writing the log, do not perform additional actions or start coding.

**Always use this template for recording logs:**

```
---
date: <enter the current date as YYYY-MM-DD>
---

## Raw Input
<copy the user's prompt here, verbatim>

## AI Analysis
<write a point form summary of the prompt and any pertinent considerations here>
```

