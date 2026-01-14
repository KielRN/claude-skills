# Ralph User Guide

Welcome to Ralph! This guide will help you understand and use Ralph, an autonomous AI coding agent that builds features for you automatically.

## What is Ralph?

Ralph is a coding automation tool that:
- Reads a list of tasks you want done (called a "PRD")
- Implements each task one at a time
- Tests each change to make sure it works
- Commits working code to git
- Moves on to the next task automatically

Think of Ralph as a junior developer who:
- Works independently
- Follows instructions exactly
- Tests their work before committing
- Learns from mistakes
- Never gets tired

## Table of Contents

1. [Quick Start](#quick-start)
2. [How Ralph Works](#how-ralph-works)
3. [Creating Your First PRD](#creating-your-first-prd)
4. [Running Ralph](#running-ralph)
5. [Understanding the Output](#understanding-the-output)
6. [Writing Good User Stories](#writing-good-user-stories)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Usage](#advanced-usage)

---

## Quick Start

### Prerequisites

Before using Ralph, you need:
1. **Claude Code CLI** installed (the `claude` command must work in your terminal)
2. **Git** initialized in your project (`git init` if not already done)
3. A code project you want to add features to

### 5-Minute Setup

1. **Copy Ralph to your project**
   ```bash
   # Copy these files to your project folder:
   # - ralph.ps1 (Windows) or ralph.sh (Mac/Linux)
   # - SKILL.md
   # - CLAUDE.md (optional but helpful)
   ```

2. **Create a PRD** (Product Requirements Document)
   ```bash
   # Open Claude Code in your project
   claude

   # Ask Claude to create a PRD
   /prd
   ```

   Claude will ask you questions and create a `PRD.md` file with tasks.

3. **Run Ralph**
   ```powershell
   # Windows
   .\ralph.ps1 -MaxIterations 10

   # Mac/Linux
   chmod +x ralph.sh  # First time only
   ./ralph.sh 10
   ```

4. **Watch it work!**
   Ralph will implement each task, test it, and commit it automatically.

---

## How Ralph Works

### The Loop Concept

Ralph works in a loop. Each loop iteration:

```
┌─────────────────────────────────────────────────┐
│  Iteration 1: Start fresh                      │
│  1. Read PRD.md - find first incomplete task   │
│  2. Read progress.txt - learn from previous    │
│  3. Write the code for that ONE task           │
│  4. Run tests - does it work?                  │
│  5. If YES: Mark complete, commit, log success │
│     If NO: Log what failed, don't commit       │
└─────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────┐
│  Iteration 2: Start fresh again (no memory!)   │
│  1. Read PRD.md - find next incomplete task    │
│  2. Read progress.txt - see what worked        │
│  3. Write the code...                          │
│  ... (repeat)                                  │
└─────────────────────────────────────────────────┘
```

### Key Insight: Fresh Start Each Time

This is what makes Ralph special - each iteration starts with a **brand new Claude instance** that has:
- ✅ Access to PRD.md (the task list)
- ✅ Access to progress.txt (learnings from previous iterations)
- ✅ Access to your code (to read and modify)
- ❌ NO memory of previous iterations

**Why this matters:**
- Ralph can't get confused by earlier context
- Each task is independent and focused
- If one task fails, the next iteration tries again with fresh perspective
- You can stop and restart anytime without losing progress

### The Critical Constraint: One Context Window

Each task must be completable in about **10 minutes of AI work**. This is because:
- Claude has a limited "context window" (how much it can think about at once)
- If a task is too big, Ralph runs out of thinking space before finishing
- Result: incomplete, broken code

**Good tasks** (fit in one iteration):
- Add a "status" column to a database table
- Create a single button component
- Add a filter dropdown to a page

**Bad tasks** (too big):
- Build the entire dashboard
- Add complete authentication system
- Implement drag-and-drop with persistence

---

## Creating Your First PRD

A PRD (Product Requirements Document) is just a fancy name for "a list of tasks written in a specific format."

### Using the /prd Skill (Easiest Way)

1. Open Claude in your project:
   ```bash
   claude
   ```

2. Trigger the PRD skill:
   ```
   /prd
   ```

3. Answer the questions Claude asks you:
   ```
   Claude: What is the primary goal of this feature?
   A. Improve user onboarding
   B. Increase retention
   C. Add new functionality
   D. Other

   You: 1C  (Just respond with the letter)
   ```

4. Claude creates two files:
   - `PRD.md` - Your task list
   - `progress.txt` - Empty log file (Ralph fills this in)

### PRD Structure Explained

Here's what a PRD looks like:

```markdown
# PRD: Task Priority System

## Introduction
What this feature does and why it matters.

## Goals
- Specific goal 1
- Specific goal 2
- Specific goal 3

## User Stories

### US-001: Add priority field to database
**Description:** As a developer, I need to store task priority
so it persists across sessions.

**Acceptance Criteria:**
- [ ] Add priority column: 'high' | 'medium' | 'low' (default 'medium')
- [ ] Generate and run migration successfully
- [ ] Typecheck passes

### US-002: Display priority indicator
**Description:** As a user, I want to see task priority at a glance.

**Acceptance Criteria:**
- [ ] Each task card shows colored badge (red/yellow/gray)
- [ ] Priority visible without hovering
- [ ] Typecheck passes
- [ ] Verify changes work in browser

## Non-Goals
- No automatic priority assignment
- No priority-based notifications
```

### User Story Format

Each user story has:

1. **ID Number**: US-001, US-002, etc. (sequential)
2. **Title**: Short description
3. **Description**: "As a [user], I want [feature] so that [benefit]"
4. **Acceptance Criteria**: Checkboxes `- [ ]` that Ralph marks complete `- [x]`

---

## Running Ralph

### Windows (PowerShell)

```powershell
# Basic usage (10 iterations max)
.\ralph.ps1

# Custom iterations and delay
.\ralph.ps1 -MaxIterations 20 -SleepSeconds 3

# What this does:
# -MaxIterations: Stop after this many tries (default: 10)
# -SleepSeconds: Wait this long between iterations (default: 2)
```

### Mac/Linux (Bash)

```bash
# First time only - make it executable
chmod +x ralph.sh

# Basic usage (10 iterations max)
./ralph.sh

# Custom iterations and delay
./ralph.sh 20 3
```

### What You'll See

```
Starting Ralph - Max 10 iterations

===========================================
  Iteration 1 of 10
===========================================
[Claude starts working on first task...]
[You'll see Claude's thought process]
[Tests run...]
[Git commit happens...]

===========================================
  Iteration 2 of 10
===========================================
[Claude starts fresh, finds next task...]
...
```

### When Ralph Stops

Ralph stops when:

1. ✅ **All tasks complete** - You'll see:
   ```
   ===========================================
     All tasks complete after 5 iterations!
   ===========================================
   ```

2. ❌ **Max iterations reached** - You'll see:
   ```
   ===========================================
     Reached max iterations (10)
   ===========================================
   ```
   This means there are still incomplete tasks. Check `progress.txt` to see why.

---

## Understanding the Output

### Files Ralph Creates/Modifies

#### 1. PRD.md (Your task list)
Ralph reads this to know what to do next and marks tasks complete:

```markdown
Before:
- [ ] Add status column to database

After Ralph completes it:
- [x] Add status column to database
```

#### 2. progress.txt (Learning log)
Ralph writes to this after each iteration:

```markdown
## Iteration 1 - Add status column to database
- Added migration file: 001_add_status.sql
- Files changed: schema.sql, migrations/001_add_status.sql
- Learnings for future iterations:
  - Database uses PostgreSQL syntax
  - Migrations must run before app starts
  - Use 'status' not 'state' (consistency with other tables)
---

## Iteration 2 - Display status badge on cards
- Added StatusBadge.tsx component
- Files changed: components/StatusBadge.tsx, pages/TaskCard.tsx
- Learnings for future iterations:
  - Project uses Tailwind CSS for styling
  - Components in /components directory
  - Use existing Badge component as base (found in /components/ui)
---
```

**Why this matters:** Each fresh Claude instance reads this to learn from previous work.

#### 3. Your Code
Ralph modifies your actual code files to implement features.

#### 4. Git Commits
Ralph creates a commit for each completed task:

```bash
git log --oneline
a1b2c3d feat: Display status badge on task cards
e4f5g6h feat: Add status column to database
```

### AGENTS.md (Optional)

If this file exists in your project, Ralph may add reusable patterns:

```markdown
# Agent Instructions

## Learnings

### Database Patterns
- This project uses Prisma ORM
- Migrations in /prisma/migrations
- Always run `npx prisma generate` after schema changes

### UI Patterns
- Use Tailwind CSS, not inline styles
- Components in /src/components
- Reuse existing shadcn/ui components
```

---

## Writing Good User Stories

### The Golden Rules

#### 1. One Task = 10 Minutes Max

**Too Big:**
```markdown
### US-001: Build dashboard
- [ ] Create dashboard layout
- [ ] Add charts for analytics
- [ ] Add filters
- [ ] Make it responsive
```

**Right Size (split into 4 stories):**
```markdown
### US-001: Create dashboard layout
- [ ] Add DashboardPage.tsx with header and grid
- [ ] Typecheck passes
- [ ] Verify changes work in browser

### US-002: Add analytics chart component
- [ ] Create AnalyticsChart.tsx with sample data
- [ ] Display in dashboard grid
- [ ] Typecheck passes
- [ ] Verify changes work in browser

### US-003: Add filter dropdown
- [ ] Create FilterDropdown.tsx component
- [ ] Add to dashboard header
- [ ] Typecheck passes
- [ ] Verify changes work in browser

### US-004: Connect filters to charts
- [ ] Wire filter state to chart component
- [ ] Charts update when filter changes
- [ ] Typecheck passes
- [ ] Verify changes work in browser
```

#### 2. Order Matters (Dependencies First)

**Wrong Order:**
```markdown
US-001: Display user profile page (needs database schema)
US-002: Add users table to database
```

Ralph will fail on US-001 because the database doesn't exist yet!

**Correct Order:**
```markdown
US-001: Add users table to database
US-002: Display user profile page
```

**Dependency Chain:**
1. Database schema
2. Backend API/functions
3. UI components
4. Summary/dashboard views

#### 3. Acceptance Criteria Must Be Checkable

**Bad (too vague):**
```markdown
- [ ] Works well
- [ ] Good UX
- [ ] Handles edge cases properly
```
How does Ralph know if "works well" is true?

**Good (specific and verifiable):**
```markdown
- [ ] Button changes color when clicked
- [ ] Error message displays when email is invalid
- [ ] Form submits to /api/contact endpoint
- [ ] Success message appears after submission
- [ ] Typecheck passes
- [ ] Verify changes work in browser
```

#### 4. Always Include These Criteria

**For ALL stories:**
```markdown
- [ ] Typecheck passes
```

**For UI stories (anything user sees):**
```markdown
- [ ] Verify changes work in browser
```

### Example: Well-Written Story

```markdown
### US-003: Add delete button to task cards

**Description:** As a user, I want to delete tasks I no longer need
so I can keep my task list clean.

**Acceptance Criteria:**
- [ ] Red delete button with trash icon appears on each task card
- [ ] Clicking delete shows confirmation dialog with "Cancel" and "Delete" options
- [ ] Clicking "Delete" removes task from list immediately
- [ ] Clicking "Cancel" closes dialog without deleting
- [ ] Deleted tasks are removed from database
- [ ] Typecheck passes
- [ ] Verify changes work in browser
```

Why this is good:
- ✅ Single, focused feature (just the delete button)
- ✅ Describes user benefit
- ✅ Every criterion is verifiable
- ✅ Includes required criteria (typecheck, browser verification)
- ✅ Can be completed in ~10 minutes

---

## Troubleshooting

### Problem: Ralph keeps failing the same task

**Likely cause:** The task is too big.

**Solution:**
1. Stop Ralph (Ctrl+C)
2. Open `PRD.md`
3. Split the failing task into smaller tasks:
   ```markdown
   Before:
   - [ ] US-005: Add authentication system

   After:
   - [ ] US-005: Add users table and auth columns
   - [ ] US-006: Create login form component
   - [ ] US-007: Add session middleware
   - [ ] US-008: Protect routes with auth check
   ```
4. Run Ralph again

### Problem: Tests keep failing

**Likely causes:**
1. Test configuration issue
2. Missing dependencies
3. Task too complex

**Solutions:**
1. Read `progress.txt` to see the actual error
2. Fix the issue manually:
   ```bash
   # See what's wrong
   cat progress.txt

   # Fix it yourself
   npm install missing-package

   # Update PRD.md to mark that task complete
   # Edit: [ ] → [x]
   ```
3. Continue Ralph on next task

### Problem: Ralph makes wrong assumptions

**Example:** Ralph adds a button but puts it in the wrong place.

**Solution:** Be more specific in acceptance criteria:
```markdown
Bad:
- [ ] Add a button

Good:
- [ ] Add a blue "Save" button to the bottom-right of the form
- [ ] Button appears below the email input field
- [ ] Button has rounded corners and shadow effect
```

### Problem: Reached max iterations with work remaining

**This is normal!** It means:
- You have more tasks than iterations allowed
- Some tasks failed and need manual fixing

**Solutions:**
1. **Continue where you left off:**
   ```bash
   # Run another batch
   .\ralph.ps1 -MaxIterations 10
   ```

2. **Review progress:**
   ```bash
   # Check what's been done
   git log --oneline

   # Check what failed
   cat progress.txt
   ```

3. **Fix failures manually if needed**, then continue

### Problem: Ralph commits broken code

**This shouldn't happen** - Ralph is supposed to test first. But if it does:

```bash
# Undo the last commit
git reset HEAD~1

# Fix the issue manually
# (edit files)

# Commit your fix
git add .
git commit -m "fix: corrected [issue]"

# Update PRD.md to mark task as complete (so Ralph skips it)
# Change [ ] to [x] for that task
```

---

## Advanced Usage

### Customizing Ralph's Behavior

#### Increase Iterations for Large Projects
```powershell
# Windows - run 50 iterations
.\ralph.ps1 -MaxIterations 50

# Mac/Linux
./ralph.sh 50
```

#### Adjust Sleep Time Between Iterations
```powershell
# Wait 5 seconds between iterations (gives you time to watch)
.\ralph.ps1 -SleepSeconds 5

# No wait (fastest, but hard to follow)
.\ralph.ps1 -SleepSeconds 0
```

### Running Specific Tasks Only

Edit `PRD.md` to mark tasks you want to skip as complete:

```markdown
### US-001: Add database column
- [x] ... (Mark complete - Ralph will skip)

### US-002: Add UI component
- [ ] ... (Ralph will do this one)

### US-003: Add tests
- [x] ... (Marked complete - Ralph will skip)

### US-004: Update documentation
- [ ] ... (Ralph will do this after US-002)
```

### Using AGENTS.md for Cross-Project Knowledge

Create an `AGENTS.md` file in your Ralph directory (not your project) to store patterns that apply to ALL your projects:

```markdown
# Agent Instructions

## General Patterns

### React Projects
- Always use functional components, not class components
- Use hooks (useState, useEffect) for state management
- Components go in /src/components
- One component per file

### Node.js APIs
- Use Express.js routing patterns
- Middleware in /middleware folder
- Routes in /routes folder
- Always validate input with Joi or Zod

### Testing
- Use Jest for unit tests
- Test files: ComponentName.test.tsx
- Run tests with: npm test
```

Ralph will read this and follow these patterns across all projects.

### Pausing and Resuming

Ralph can be stopped and restarted anytime:

```bash
# Start Ralph
.\ralph.ps1 -MaxIterations 10

# Press Ctrl+C to stop after iteration 5

# Later, resume from where you left off
.\ralph.ps1 -MaxIterations 10
# Ralph reads PRD.md and continues with task 6
```

### Manual Interventions

You can work alongside Ralph:

1. **Let Ralph do some tasks**
2. **Stop Ralph (Ctrl+C)**
3. **Manually implement a complex task**
4. **Mark it complete in PRD.md:**
   ```markdown
   - [x] US-007: Complex authentication flow
   ```
5. **Restart Ralph** - it will skip US-007 and do the rest

---

## Tips for Success

### Start Small
Don't try to build an entire app with Ralph on your first try. Start with:
- 3-5 simple tasks
- 5 iterations max
- Review the output carefully

### Be Specific
The more specific your acceptance criteria, the better Ralph performs:

**Vague:**
```markdown
- [ ] Add a nice-looking button
```

**Specific:**
```markdown
- [ ] Add a blue button with white text that says "Submit"
- [ ] Button is 120px wide and 40px tall
- [ ] Button has 8px rounded corners
- [ ] Button shows pointer cursor on hover
```

### Review Early and Often
After 2-3 iterations:
1. Stop Ralph
2. Check the git commits: `git log`
3. Review the code changes: `git diff HEAD~3`
4. Test the changes yourself
5. Adjust PRD.md if needed
6. Continue

### Use Progress Log Learnings
After Ralph completes a few tasks, read `progress.txt`. Look for patterns:

```markdown
## Learnings
- Project uses Tailwind CSS (don't write custom CSS)
- API routes in /pages/api (not /api)
- Database uses Supabase (not raw SQL)
```

Use these learnings to write better acceptance criteria for remaining tasks.

---

## Real-World Examples

### Example 1: Adding Task Priority Feature

**PRD.md:**
```markdown
# PRD: Task Priority System

## User Stories

### US-001: Add priority column to database
**Description:** Store priority for each task.

**Acceptance Criteria:**
- [ ] Add 'priority' column to tasks table: 'high' | 'medium' | 'low'
- [ ] Default value is 'medium'
- [ ] Migration runs successfully
- [ ] Typecheck passes

### US-002: Display priority badge
**Description:** Show priority on task cards.

**Acceptance Criteria:**
- [ ] Each task card shows colored badge (red=high, yellow=medium, gray=low)
- [ ] Badge displays to the right of task title
- [ ] Typecheck passes
- [ ] Verify changes work in browser

### US-003: Add priority selector
**Description:** Let users change task priority.

**Acceptance Criteria:**
- [ ] Dropdown in task edit form with options: High, Medium, Low
- [ ] Current priority shows as selected
- [ ] Changing priority saves immediately
- [ ] Typecheck passes
- [ ] Verify changes work in browser
```

**Running Ralph:**
```powershell
.\ralph.ps1 -MaxIterations 5
```

**Result:**
- Iteration 1: Adds database column (git commit 1)
- Iteration 2: Adds badge component (git commit 2)
- Iteration 3: Adds priority selector (git commit 3)
- Total: 3 working commits in ~15 minutes

### Example 2: Building a Contact Form

**PRD.md:**
```markdown
# PRD: Contact Form

## User Stories

### US-001: Create contact form component
**Description:** Basic form structure.

**Acceptance Criteria:**
- [ ] Form has fields: name, email, message
- [ ] Form has blue "Send" button
- [ ] All fields are required
- [ ] Typecheck passes
- [ ] Verify changes work in browser

### US-002: Add form validation
**Description:** Validate inputs before submission.

**Acceptance Criteria:**
- [ ] Email field validates email format
- [ ] Message must be at least 10 characters
- [ ] Error messages display in red below invalid fields
- [ ] Submit button disabled until form is valid
- [ ] Typecheck passes
- [ ] Verify changes work in browser

### US-003: Create API endpoint
**Description:** Backend to receive form submissions.

**Acceptance Criteria:**
- [ ] POST endpoint at /api/contact
- [ ] Accepts JSON: {name, email, message}
- [ ] Returns 200 on success, 400 on invalid data
- [ ] Typecheck passes

### US-004: Connect form to API
**Description:** Submit form data to backend.

**Acceptance Criteria:**
- [ ] Form submits to /api/contact on button click
- [ ] Loading spinner shows during submission
- [ ] Success message displays after submission
- [ ] Error message displays if submission fails
- [ ] Form clears after successful submission
- [ ] Typecheck passes
- [ ] Verify changes work in browser
```

**Running Ralph:**
```powershell
.\ralph.ps1 -MaxIterations 10
```

---

## Next Steps

Now that you understand Ralph:

1. **Try it out** with a small 3-task PRD
2. **Read CLAUDE.md** for technical details about how Ralph works internally
3. **Read SKILL.md** to understand the PRD generator
4. **Experiment** with different project types
5. **Share learnings** by updating AGENTS.md with patterns you discover

## Getting Help

If Ralph isn't working as expected:

1. **Check progress.txt** - shows detailed error messages
2. **Review PRD.md** - are tasks too big?
3. **Test manually** - can YOU complete the task in 10 minutes?
4. **Read the output** - Ralph explains what it's doing
5. **Start smaller** - fewer, simpler tasks to test your setup

## Summary

**Ralph in 3 sentences:**
1. Ralph reads your task list (PRD.md) and implements tasks one at a time
2. Each iteration starts fresh, so tasks must be small and independent
3. Ralph tests each task and only commits if tests pass

**Key to success:**
- Write small, specific tasks
- Order tasks by dependency
- Use verifiable acceptance criteria
- Start with fewer iterations to test
- Review and adjust as you go

Happy coding with Ralph! 🤖
