# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**Ralph** is an autonomous AI coding agent that implements features iteratively by breaking down Product Requirements Documents (PRDs) into small, atomic tasks. Each task is completed in a fresh Claude instance with no memory of previous iterations, ensuring consistency and preventing context drift.

### Core Components

- **[ralph.ps1](ralph.ps1)** / **[ralph.sh](ralph.sh)**: Loop scripts that spawn fresh Claude instances per iteration
- **[SKILL.md](SKILL.md)**: PRD Generator skill definition for creating well-structured requirements
- **[AGENTS.md](AGENTS.md)**: Reusable patterns and learnings discovered during implementation (cross-project knowledge)
- **PRD.md**: Generated requirements document with user stories (created per project in working directory)
- **progress.txt**: Iteration log capturing learnings and patterns (created per project in working directory)
- **[cleanup.ps1](cleanup.ps1)**: Utility script to organize temporary files into temp folder

## How Ralph Works

Ralph operates as a loop that:
1. Spawns a fresh Claude instance with no memory of previous iterations
2. Reads PRD.md to find the next incomplete task (marked `[ ]`)
3. Checks progress.txt for learnings from previous iterations
4. Implements ONE atomic task
5. Runs tests/typecheck to verify
6. Only marks complete `[x]` and commits if tests pass
7. Logs progress and repeats until all tasks are complete

### Key Constraint: Context Window Limitation

**Each user story MUST be completable in ONE context window (~10 min of AI work).**

Since Ralph spawns fresh instances per iteration with no memory, stories that are too large will run out of context before finishing and produce broken code.

## Running Ralph

### Prerequisites
- Claude Code CLI installed and configured (`claude` command available)
- PRD.md file in your working directory
- progress.txt file in your working directory (created automatically by `/prd` skill)

### PowerShell (Windows)
```powershell
.\ralph.ps1 -MaxIterations 10 -SleepSeconds 2
```

### Bash (Unix/Linux/Mac)
```bash
# Make script executable (first time only)
chmod +x ralph.sh

# Run Ralph
./ralph.sh [max_iterations] [sleep_seconds]

# Example: Run up to 15 iterations with 3 second delay
./ralph.sh 15 3
```

**Parameters:**
- `MaxIterations` / `max_iterations`: Maximum number of iterations to run (default: 10)
- `SleepSeconds` / `sleep_seconds`: Delay between iterations in seconds (default: 2)

**Exit Conditions:**
- Ralph exits successfully when all tasks are marked complete (outputs `<promise>COMPLETE</promise>`)
- Ralph exits with error code 1 if max iterations reached with incomplete tasks
- Each iteration runs with `--dangerously-skip-permissions` flag to enable autonomous operation

## PRD Structure & Requirements

### User Story Format
```markdown
### US-001: [Title]
**Description:** As a [user], I want [feature] so that [benefit].

**Acceptance Criteria:**
- [ ] Specific verifiable criterion
- [ ] Another criterion
- [ ] Typecheck passes
- [ ] [UI stories] Verify changes work in browser
```

### Story Sizing Rules

**Right-sized stories (completable in one iteration):**
- Add a database column and migration
- Add a single UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

**Too big (MUST split):**
- "Build the dashboard" → Split into: Schema, queries, UI components, filters
- "Add authentication" → Split into: Schema, middleware, login UI, session handling
- "Add drag and drop" → Split into: Drag events, drop zones, state update, persistence

**Rule of thumb:** If you cannot describe the change in 2-3 sentences, it is too big.

### Story Ordering (Critical)

Stories execute in priority order. Earlier stories MUST NOT depend on later ones.

**Correct dependency order:**
1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views that aggregate data

### Acceptance Criteria Requirements

Each criterion must be verifiable, not vague.

**Good criteria:**
- "Add `status` column to tasks table with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"
- "Clicking delete shows confirmation dialog"

**Bad criteria:**
- "Works correctly"
- "Good UX"
- "Handles edge cases"

**Always include:**
- "Typecheck passes" (for all stories)
- "Verify changes work in browser" (for UI stories)

## Progress Tracking

### progress.txt Format

```markdown
## Iteration [N] - [Task Name]
- What was implemented
- Files changed
- Learnings for future iterations:
  - Patterns discovered
  - Gotchas encountered
  - Useful context
---
```

### Completion Rules

**Mark complete and commit ONLY if:**
- Tests pass
- Typecheck passes
- All acceptance criteria met

**DO NOT mark complete if:**
- Tests are failing
- Implementation is partial
- Unresolved errors exist
- Necessary files or dependencies missing

Instead, log what went wrong in progress.txt so the next iteration can learn and fix it.

## PRD Generator Skill

The `/prd` skill (defined in SKILL.md) creates structured requirements documents.

### Skill Workflow

1. Ask 3-5 clarifying questions with lettered options (e.g., "1A, 2C, 3B")
2. Generate structured PRD based on answers
3. Save to `PRD.md`
4. Create empty `progress.txt`

**Important:** The PRD skill does NOT implement - it only creates the requirements.

### Triggering the PRD Skill

Use when:
- Planning a new feature
- Starting a new project
- User asks to "create a prd", "write prd for", "plan this feature", "requirements for", "spec out"

## Architecture Principles

### Atomicity
Each iteration must be fully independent and self-contained. No shared state between iterations except what's in PRD.md and progress.txt.

### Verification-First
Never mark tasks complete without passing tests. Broken code should be documented in progress.txt, not committed.

### Knowledge Transfer
Use progress.txt Learnings section to pass patterns and gotchas to future iterations. If patterns are reusable across projects, add them to AGENTS.md (if it exists).

### Failure Recovery
If an iteration fails (tests fail, errors occur), the next iteration learns from progress.txt and attempts a fix. This is by design - Ralph is resilient through iteration.

## File Management

### Temporary Files
The Claude CLI creates temporary files (like `tmpclaude-*-cwd`) during execution. Ralph automatically moves these to the `temp/` folder after each iteration, keeping your workspace clean.

If you need to manually clean up temp files between runs:

```powershell
# Windows
.\cleanup.ps1

# Unix/Linux/Mac
# Create bash version if needed or manually move files to temp/
```

### .gitignore
The project includes a [.gitignore](.gitignore) that excludes:
- temp/ directory (temporary Claude files)
- node_modules/ (if using Node.js in your project)
- .env files (environment variables and secrets)

## Workflow Summary

1. **Plan**: Use `/prd` skill or manually create PRD.md with user stories
2. **Execute**: Run ralph.ps1 or ralph.sh to start autonomous implementation
3. **Monitor**: Watch progress in console output and check progress.txt for detailed logs
4. **Iterate**: Ralph continues until all tasks complete or max iterations reached
5. **Review**: Check git commits for each completed task
6. **Learn**: Review AGENTS.md for patterns that can help future projects

## Best Practices

### For Effective PRDs
- Break features into the smallest possible user stories
- Order stories by dependency (database → backend → frontend)
- Write verifiable acceptance criteria (avoid "works well" type criteria)
- Always include "Typecheck passes" as a criterion
- For UI changes, include "Verify changes work in browser"

### For Smooth Execution
- Start with fewer iterations (5-10) to test your PRD structure
- Review progress.txt after a few iterations to catch issues early
- If Ralph gets stuck on a task, it may be too large - split it in PRD.md
- Document learnings in progress.txt for cross-iteration knowledge transfer
- Add reusable patterns to AGENTS.md for cross-project knowledge

### Troubleshooting
- **Task never completes**: Story may be too large, split into smaller tasks
- **Tests keep failing**: Check progress.txt for error patterns, may need manual intervention
- **Ralph makes wrong assumptions**: Improve acceptance criteria clarity in PRD.md
- **Context window exceeded**: Story is too complex, break into multiple atomic stories
