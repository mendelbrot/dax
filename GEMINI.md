# Dax Project Context

@.cursor/rules/overview.mdc
@.cursor/rules/backend.mdc
@.cursor/rules/frontend.mdc

# AI-Assisted Development Workflow

## Knowledge Management (`notes-dax/`)
We use the `notes-dax` folder to manage project state and knowledge.

- **`notes-dax/plans/`**: Functional specifications and task lists.
  - Create a plan file (e.g., `feature-name.md`) before starting code.
  - Use `roadmap.md` for high-level tracking.
- **`notes-dax/knowledge/`**: The "Second Brain".
  - Stores explanations of concepts, patterns, and decisions.
  - Reference these when needing to recall how/why things work.
- **`notes-dax/dev-logs/`**: Context and decision records.
  - Log complex debugging sessions or architectural choices.

### DevLog Convention
- **Trigger:** Start a prompt with **"Log:"** (case-insensitive) to automatically archive the session.
- **Action:** I will create a new entry in `notes-dax/dev-logs/YYYY-MM-DD-[topic].md` containing:
    - **Raw Input:** Your exact message.
    - **AI Summary & Analysis:** A structured breakdown and next steps.

## Interaction Loop
1. **Plan:** Discuss and draft a file in `plans/`.
2. **Act:** Implement based on the plan.
3. **Document:** Save new learnings to `knowledge/` or `dev-logs/`.