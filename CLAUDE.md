<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->


# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.


## Working Style & Approach


**CRITICAL: Think First, Code Once - Not the Other Way Around**


When tackling any non-trivial task, especially those involving complex systems (UI interactions, state management, API integrations, etc.):


### Required Process
1. 
**ANALYZE THOROUGHLY FIRST**
 - Read and understand ALL relevant code before making any changes
2. 
**MAP THE SYSTEM**
 - Identify all dependencies, interactions, and potential side effects
3. 
**CLARIFY REQUIREMENTS**
 - If ANYTHING is unclear, ambiguous, or could be interpreted multiple ways, 
**STOP and ASK QUESTIONS**
. Never assume or guess at requirements.
4. 
**DESIGN A COMPLETE SOLUTION**
 - Think through the entire approach on "paper" first
5. 
**PRESENT THE PLAN**
 - Explain the strategy clearly before writing any code
6. 
**IMPLEMENT CAREFULLY**
 - Make changes systematically, following the agreed plan
7. 
**STICK TO THE PLAN**
 - Don't pivot to quick fixes that create new problems


### Usage of console.log in debugging
- It is IMPERATIVE that in order to understand what's happening in the system, you use `console.log` in critical points of the system to understand what's TRULY happening!
- If the user reports an error, you MUST UNDERSTAND what's going on not just through the analysis of the code, but through the analysis of the logs you write


### Absolutely Forbidden
- ❌ Making reactive changes without understanding root causes
- ❌ Fixing one bug and creating another (going in circles)
- ❌ Changing approach multiple times mid-task
- ❌ Quick fixes that break other things
- ❌ Jumping to implementation before thorough analysis
- ❌ Closing a Beads task without running `bd show <id>` IMMEDIATELY before `bd close <id>`
- ❌ Committing or pushing directly to the main branch (always use feature branches)


### If You Get Stuck
- 
**STOP**
 - Don't keep trying random fixes
- 
**STEP BACK**
 - Re-analyze the entire system
- 
**ADD CONSOLE LOGS**
 - Only by seeing the logs you can understand what's going on
- 
**ASK**
 - Request clarification or context from the user
- 
**REDESIGN**
 - Create a new plan based on better understanding


**Remember:**
 Breaking more things than you fix wastes time and causes frustration. Spending 10 minutes on proper analysis upfront is better than 60 minutes going in circles.


## Git Workflow

### STRICT RULE: Never Commit to Main

**ALWAYS work on feature branches. NEVER commit or push directly to main.**

✅ **CORRECT workflow**:
1. Create a feature branch: `git checkout -b feat/feature-name` or `git checkout -b fix/bug-name`
2. Make changes and commit to the feature branch
3. Push feature branch: `git push -u origin feat/feature-name`
4. User will create PR and merge to main

❌ **FORBIDDEN**:
```bash
git checkout main
git commit -m "changes"  # ❌ NEVER commit to main
git push origin main      # ❌ NEVER push to main
```

**Branch naming conventions**:
- `feat/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Test additions or changes

## Issue Tracking


ALWAYS use `bd` (Beads) for issue tracking.


### STRICT RULE: Show Task Before Closing

⚠️ **CRITICAL - NO EXCEPTIONS** ⚠️

Before closing ANY Beads task, you MUST follow this EXACT sequence:
1. Run `bd show <id>` to display the task details
2. Verify all acceptance criteria are met (read the output!)
3. IMMEDIATELY run `bd close <id>` in the next command

**This applies EVERY SINGLE TIME you close a task.**
- Even if you showed the task earlier in the conversation - SHOW IT AGAIN
- Even if you "know" what's in the task - SHOW IT ANYWAY
- No shortcuts, no combining commands - SHOW then CLOSE

❌ **ANTI-PATTERN** (will be rejected):
```bash
# Showing task, then doing other work, then closing without showing again
bd show mealfinding-5hy.22
# ... other commands ...
bd close mealfinding-5hy.22  # ❌ WRONG - must show again first!
```

✅ **CORRECT PATTERN**:
```bash
bd show mealfinding-5hy.22
bd close mealfinding-5hy.22 -r "reason"  # ✅ RIGHT - showed immediately before
```

**The user cannot see the show output if you don't run it right before closing.**


### STRICT RULE: Every `bd create` MUST include `-d`


❌ 
**FORBIDDEN**
 — will be rejected:
```bash
bd create "Update file.ts" -t task
```


✅ 
**REQUIRED**
 — every issue needs full context:
```bash
bd create "Title" -t task -p 2 -l "label" -d "## Requirements
- What needs to be done


## Acceptance Criteria  
- How to verify it's done


## Context
- Relevant file paths, spec references"
```


**No exceptions.**
 If you don't have enough context for `-d`, ask the user first.