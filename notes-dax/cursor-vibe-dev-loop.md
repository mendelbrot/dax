Here are the key things you should know about task management in Cursor (as of early 2026). Cursor's Agent and Composer features make it powerful for handling everything from quick fixes to large, multi-step features in a monorepo like yours.

### 1. Understand the Core Modes for Tasks
Cursor's task handling centers on the **Composer tab** (Cmd/Ctrl + K to open), which integrates the fast Composer model with different modes:

- **Ask Mode** — Best for initial exploration, questions, or light planning. It's read-only (no code changes), great for understanding your codebase (e.g., "How does authentication work in /client-flutter?") or brainstorming without risk.
- **Plan Mode** (toggle with Shift+Tab) — Essential for any non-trivial task. The agent researches your codebase, asks clarifying questions, and generates a detailed Markdown plan (saved in `.cursor/plans/`) with steps, file references, and rationale. Always start complex tasks here—you can edit the plan directly before execution.
- **Agent Mode** — For autonomous execution. The agent edits files, runs terminal commands (e.g., flutter build, supabase commands), searches the codebase semantically, and iterates. Ideal for implementing features, refactors, or bug fixes in your Flutter/Supabase setup.
- **Debug Mode** — Specialized for tricky bugs. It hypothesizes issues, adds logging, runs code to collect data, and fixes iteratively.

Switch modes as needed—start in Plan/Ask, then flip to Agent for execution.

### 2. Break Down and Track Tasks Effectively
- **Start every meaningful task with a plan**: This is the #1 official best practice. Prompt like: "Plan implementing real-time syncing for feature X in /client-flutter using Supabase." Review/edit the plan, then let the agent execute. Plans prevent hallucinations and make resumption easy.
- **Use built-in Todos**: The agent can generate and manage structured task lists (e.g., "Break this feature into todos with priorities and effort estimates"). It tracks progress automatically in complex projects.
- **For your project**: Put high-level task lists, roadmaps, or updated plans in your `/notes-dax` folder (e.g., `tasks.md` or `feature-roadmap.md`). @mention them in prompts (`@notes-dax/tasks.md`) so agents always see current priorities. This keeps collaborators in sync via Git.
- **New conversation per task/feature**: Avoid long, noisy threads. Start fresh for each logical unit (e.g., one chat for a Flutter UI component, another for a Supabase schema change). This keeps context focused.

### 3. Handle Large/Complex Tasks in a Monorepo
- **Delegate subtasks** → Let the agent handle repetitive work (tests, docs, refactors) autonomously.
- **Parallel agents** → Run multiple agents at once (up to 8, with Git worktree isolation) for independent tasks—like one fixing Flutter UI while another updates Supabase functions.
- **Background/cloud agents** → Great for long-running tasks (e.g., generating full test coverage). They work offline, create branches, and notify you on completion.
- **Checkpoints** → Automatic snapshots let you rollback if things go off-track.
- **Context tips** → Trust the agent to search your monorepo (it uses grep/semantic tools). Only @ specific files/folders if needed (e.g., `@client-flutter` or `@Supabase`). Your project rules (from `.cursor/rules`) provide persistent context automatically.

### 4. Review and Iterate Safely
- Watch diffs in real-time and interrupt (Esc) if needed.
- After completion, run "Agent Review" or "Find Issues" to self-critique changes.
- Use verifiable goals: Write tests first (TDD workflow), run commands manually if unsure, and prompt specifically (e.g., "Implement this exactly per the plan in notes-dax/guide.md").
- For security in your setup: Require confirmation for terminal commands involving Supabase deploys or migrations.

### 5. Pro Workflow Tips Tailored to Your Project
- Combine your project rules with plans: Rules handle "always-on" stuff (objectives, folder structure), while plans handle task-specific steps.
- Track architecture/notes: Ask agents to update `/notes-dax` with decisions, diagrams (Mermaid works great), or post-task summaries.
- Resume easily: Reference past plans/chats with `@Past Chats` or load saved plans.
- Git integration: Agents can commit, branch, and even open PRs—prompt for clean commits.

Overall, treat the agent like a proactive pair programmer: Plan first, guide with clear prompts and your rules/notes, review often, and break everything into small, verifiable steps. This works especially well in monorepos and scales with collaborators since everything (rules, plans, notes) is version-controlled.

If you're tackling a specific task soon, try starting in Plan Mode—it'll change how you approach things!