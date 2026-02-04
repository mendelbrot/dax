## Core Behavioral Guidelines

- **Planning First:** Always prioritize planning, understanding, and shared decision-making. Coding is the final step after a plan is agreed upon.
- **Consultative Approach:** Ask clarifying questions and discuss trade-offs before proceeding with significant changes.
- **Prompt Modifiers:**
  - `ask:` Answer the question without performing file operations or actions.
  - `log:` Automatically archive the session following the DevLog Convention.
  - `plan:` Initiate a structured planning session following the Plan Convention.


## Knowledge Management (`notes-dax/`)

We use the `notes-dax` folder to manage project state and knowledge. 
*Note: Files within `notes-dax/archive/` may contain outdated information and should be referenced with caution.*

- **`notes-dax/plans/`**: Functional specifications and task lists. Create a plan file (e.g., `YYYY-MM-DD-feature-name.md`) before starting code.
- **`notes-dax/docs/`**: **Stable Documentation.** High-level system overviews, API definitions, and user guides. These should be kept up-to-date with every feature.
- **`notes-dax/knowledge/`**: Deep-dives into specific concepts, patterns, and architectural decisions.
- **`notes-dax/assets/`**: Visual assets, including:
    - `diagrams/`: Mermaid source files (`.mmd`).
    - `images/`: Generated SVG diagrams (via `npm run mermaid`) and other images.
- **`notes-dax/dev-logs/`**: Brain dumps.

### Visual Documentation (Mermaid)
- **Workflow:** Store Mermaid source files in `notes-dax/assets/diagrams/`.
- **Generation:** Run `npm run mermaid` to generate SVG images in `notes-dax/assets/images/`.
- **Usage:** Use these diagrams in stable documentation (`notes-dax/docs/`) to illustrate system architecture and data flows.


## AI-Assisted Development Workflow

### DevLog Convention
- **Trigger:** Start a prompt with **"log:"**.
- **Action:** Create a new entry in `notes-dax/dev-logs/YYYY-MM-DD-[topic].md` containing the raw input, AI summary, analysis, and next steps.

### Plan Convention
- **Trigger:** Start a prompt with **"plan:"**.
- **Action:** Ask clarifying questions, then create a new entry in `notes-dax/plans/YYYY-MM-DD-[topic].md` containing:
    - **Objective:** Clear statement of the goal.
    - **Technical Approach:** High-level summary of the solution and architectural choices.
    - **Documentation Check:** List any files in `notes-dax/docs/` or `notes-dax/knowledge/` that need updates or creation.
    - **Task List:** A detailed, step-by-step checklist for implementation.
    - **Verification:** Specific steps to verify the work (linting, tests, etc.). (Currently, linting is the only verification done by the coding agent)

### Interaction Loop
1. **Ask:** Clarify requirements, explore the codebase, and validate assumptions.
2. **Learn:** Synthesize findings into `notes-dax/knowledge/` (new or updated articles).
3. **Plan:** Draft the implementation strategy in `notes-dax/plans/`, ensuring documentation impacts are identified.
4. **Act:** Implement the code changes and verify quality.
5. **Document:** Update stable documentation in `notes-dax/docs/` and log the session in `notes-dax/dev-logs/`.


## Dax Project Overview

Dax is a cross-platform application for saving and searching personal notes, emphasizing a clean architecture and real-time synchronization.

- **Frontend:** Flutter (`client-flutter/`)
- **Backend:** Supabase/PostgreSQL (`supabase/`)
- **Knowledge Base:** ('notes-dax/`)


## Flutter Frontend Guidelines (`client-flutter/`)

- **Verification:** NEVER run the app to verify changes (the user handles this). ALWAYS check for linting errors after tasks.
- **Code Style:** Declare widgets with `const` whenever possible (e.g., `const SizedBox(height: 48)`).
- **Architecture:** Follow the established patterns and directory structure.


## Supabase/PostgreSQL Backend Guidelines (`supabase/`)

- **Migrations:** NEVER create migration files or use `db diff`. Edit the schemas in `supabase/schemas/` directly.
- **Tooling:** NEVER run `supabase` CLI commands; the user will handle database deployments.
- **Declarative Schema:** Maintain the declarative nature of the schema files.
