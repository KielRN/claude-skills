# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the **Ralph** system - an autonomous AI coding agent that implements features iteratively by breaking down Product Requirements Documents (PRDs) into small, atomic tasks.

### Core Components

- **ralph.ps1** / **ralph.sh**: Loop scripts that spawn fresh Claude instances per iteration
- **SKILL.md**: PRD Generator skill definition for creating well-structured requirements
- **PRD.md**: Generated requirements document with user stories (created per project)
- **progress.txt**: Iteration log capturing learnings and patterns (created per project)

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

### PowerShell (Windows)
```powershell
.\ralph.ps1 -MaxIterations 10 -SleepSeconds 2
```

### Bash (Unix/Linux/Mac)
```bash
./ralph.sh [max_iterations] [sleep_seconds]
# Example: ./ralph.sh 15 3
```

**Parameters:**
- `MaxIterations`: Maximum number of iterations to run (default: 10)
- `SleepSeconds`: Delay between iterations (default: 2)

The loop exits early when all tasks show `<promise>COMPLETE</promise>`.

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
