# The run file

One Markdown file per run: the run's state, the briefs its builders and
reviewers read, and the place a run resumes from. The orchestrating session is
its only writer. It updates the file at every state change, before moving on.

## Location

`<repository root>/.task-runs/<YYYY-MM-DD>-<slug>.md`. The slug is the task's
title or the free text's first words, in lowercase ASCII kebab-case
(`2026-10-17-enseignant-model-admin.md`).

Keep `.task-runs/` out of git without touching any tracked file: append it to
the repository's exclude file if it is not there yet.

```bash
exclude="$(git rev-parse --git-common-dir)/info/exclude"
grep -qxF '.task-runs/' "$exclude" 2>/dev/null || echo '.task-runs/' >> "$exclude"
```

The exclude file is shared by every worktree of the repository and is never
committed. Ignored files are invisible to `git status`, so `review-code` never
scopes the run file as a change.

## Template

```markdown
# Run: <task title, or the free text's first words>
State: running
Source: <notion url(s), or "free text">
Branch: <branch> · Start: <short sha of HEAD when the run began>
Started: <YYYY-MM-DD HH:MM>

## Items
| # | Item | Gate | State |
|---|---|---|---|
| 1 | <title> (<notion url>) | go: <one-line reason> | committed a1b2c3d |
| 2 | <title> (<notion url>) | plan: migration | building |
| 3 | <title> (<notion url>) | go: <reason> | pending, after 2 |

## Decisions
Answers given at the preflight, and anything the human decided later, each with
the item it applies to. Text added to a Notion brief by the arguments goes here.

## 1. <title>
<notion url, or "free text">

### Brief
GOAL, REQUIREMENTS and OUT OF SCOPE, verbatim from Notion, or the free text
verbatim. Product copy stays in French.

### References
Resolved paths, with any stale path and its substitute, and the reference's
adapt / drop / add list (keep is the default).

### Plan
The approved plan, for a plan item. For a go item, only what the preflight
approved for it (copy, a decision); otherwise omitted.

### Build
The builder's report, as returned (fixer reports appended below it).

### Review
The review verdict and what happened to each finding.

### Outcome
`committed <sha> <subject>`, or `blocked: <question>` plus `stash@{n}: <message>`.

## End-of-run review
The reviewer and its model, the report path (`.task-runs/<slug>-review.md`),
each finding with its class and what happened to it, and the fix commit.

## Log
One line per event outside the items' states, with its time: a request the
human made outside the items (and what it changed, such as a database snapshot
name), a Notion write that failed, the answer to the push question.
```

## States

Item states, in order: `pending` (optionally `after <n>` for a blocker in the
run), `building`, `reviewing`, `committed <sha>`. Or `blocked: <question>` at
any point.

Run states in the header: `running` until the push question has been answered,
then `finished`. `/task resume` takes the newest file whose header still says
`running`.

## Reading it back

A builder or reviewer given the run file reads the header, `Decisions`, and
the section of its own item. The `Build` and `Review` sections are history,
not requirements. A spec check against the run file uses `Brief`, `Plan` and
`Decisions` only.
