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

<!-- BEADS:START -->
## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

<!-- BEADS:END -->

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

<!-- SHANE_PROCESS:START -->


Use 'bd' for task tracking


## Beads Issue Tracking


**BEFORE ANY WORK**
: Run `bd onboard` if you haven't already this session.


### When to Use Beads vs OpenSpec


| Situation | Tool | Action |
|-----------|------|--------|
| New feature/capability | OpenSpec | `/openspec:proposal` first |
| Approved spec ready for implementation | Both | Import tasks to Beads, then implement |
| Bug fix, small task, tech debt | Beads | `bd create` directly |
| Discovered issue during work | Beads | `bd create --discovered-from <parent>` |
| Tracking what's ready to work on | Beads | `bd ready` |
| Feature complete | OpenSpec | `/openspec:archive` |


### Daily Workflow


1.
**Orient**
: Run `bd ready --json` to see unblocked work
2.
**Pick work**
: Select highest priority ready issue OR continue in-progress work
3.
**Update status**
: `bd update <id> --status in_progress`
4.
**Implement**
: Do the work
5.
**Discover**
: File any new issues found: `bd create "Found: <issue>" -t bug --discovered-from <current-id>`
6.
**Complete**
:

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


### Converting OpenSpec Tasks to Beads


When an OpenSpec change is approved and ready for implementation:
```bash
# Create epic for the change
bd create "<change-name>" -t epic -p 1 -l "openspec:<change-name>"


# For each task in tasks.md, create a child issue
bd create "<task description>" -t task -l "openspec:<change-name>"
```


Keep OpenSpec `tasks.md` and Beads in sync:
- When completing a Beads issue, also mark `[x]` in tasks.md
- When all Beads issues for a change are closed, run `/openspec:archive`


### Importing OpenSpec Tasks to Beads


When converting OpenSpec tasks to Beads issues, ALWAYS include full context. Issues must be 
**self-contained**
 — an agent must understand the task without re-reading OpenSpec files.


**REQUIRED in every issue description:**
1. Spec file reference path
2. Relevant requirements (copy key points)
3. Acceptance criteria from the spec
4. Any technical context needed


**BAD — Never do this:**
```bash
bd create "Update stripe-price.entity.ts" -t task
```


**GOOD — Always do this:**
```bash
bd create "Add description and features fields to stripe-price.entity.ts" -t task -p 2 \
  -l "openspec:billing-improvements" \
  -d "## Spec Reference
openspec/changes/billing-improvements/specs/billing/spec.md


## Requirements
- Add 'description: string' field (nullable)
- Add 'features: string[]' field for feature list display  
- Sync fields from Stripe Price metadata on webhook


## Acceptance Criteria
- Fields populated from Stripe dashboard metadata
- Features displayed as bullet list on pricing page


## Files to modify
- apps/api/src/billing/entities/stripe-price.entity.ts
- apps/api/src/billing/stripe-webhook.service.ts"
```


**The test:**
 Could someone implement this issue correctly with ONLY the bd description and access to the codebase? If not, add more context.


### Label Conventions


- `openspec:<change-name>` - Links issue to OpenSpec change proposal
- `spec:<spec-name>` - Links to specific spec file
- `discovered` - Issue found during other work
- `tech-debt` - Technical debt items
- `blocked-external` - Blocked by external dependency


---

<!-- SHANE_PROCESS:END -->
