To provide a persistent preamble of project instructions that Cursor's AI agents (like in Composer or Agent mode) automatically consider first—before any task you assign—use **Cursor's Project Rules** feature. These rules are injected at the start of the AI's context, acting as a system-level prompt.

This setup is version-controlled, plain text (Markdown-based), and automatically applies for anyone who opens the project in Cursor, including GitHub collaborators (as long as they commit the files to the repo).

### Recommended Setup (Current Best Practice as of 2026)
1. In your project root, create a hidden directory: `.cursor/rules`  
   (Note the dot—it's hidden, but Git will track it if you commit it.)

2. Inside `.cursor/rules`, create one or more files with the `.mdc` extension (MDC = Markdown with optional metadata).  
   For your use case, start with a single main file, e.g., `project-overview.mdc`.

3. Put your instructions in that file as Markdown content. Example content for `project-overview.mdc`:

   ```
   ---
   description: Core project overview and guidelines (always apply)
   globs: **/*  # This makes the rule apply to all files in the project
   ---

   # Project Overview and Instructions

   The objective of this project is [your detailed objective here, e.g., "to build a cross-platform mobile app with real-time data syncing"].

   This is a monorepo.

   - The Flutter frontend is in /client-flutter.
   - The Supabase backend is in /Supabase.

   Please write any notes, guides, architecture decisions, or documentation to the /notes-dax folder.

   [Add any other standing instructions here, e.g.:
   - Always follow clean architecture principles.
   - Prefer functional widgets in Flutter.
   - Use Supabase edge functions for server-side logic where possible.
   - etc.]
   ```

   - The `---` sections are optional YAML frontmatter metadata.
   - `description` helps the AI decide when to apply the rule (and shows in Cursor's UI).
   - `globs: **/*` ensures it's always included, regardless of the file being edited.
   - The body is plain Markdown—your full preamble goes here.

4. Commit the `.cursor/rules` directory and its `.mdc` file(s) to Git.  
   Collaborators will get the exact same preamble automatically when they open the project in Cursor.

### Why This Works for Agents
- Project Rules are automatically included at the very beginning of the AI's context for Agent mode, Composer, inline edits, etc.
- They act as persistent "read this first" instructions.
- You can add more `.mdc` files later for scoped rules (e.g., one just for Flutter files with `globs: client-flutter/**/*`).

### Legacy Alternative (Still Works, Simpler Single File)
If you prefer an even simpler single-file approach (no directory needed):
- Create a file named `.cursorrules` (plain text/Markdown, no extension needed) in the project root.
- Put the same instructions directly in it (no metadata needed).
- This older format is deprecated but still fully supported and widely used—it achieves the same "read first" effect.
- It's the quickest to set up and share via Git.

Either way works great; the `.cursor/rules/*.mdc` approach is more flexible and future-proof for larger projects or multiple targeted rules.

Once set up, test it by starting a new Agent task—the AI should reference your objective, folder structure, etc., without you needing to paste it each time. If it doesn't pick up immediately, restart Cursor or check Settings > Project Rules to confirm they're loaded.