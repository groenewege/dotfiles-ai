# The task workflow

How client work goes from a Notion task to commits on `develop`, using three
skills: `prepare-task`, `task` and `review-code`. They work in Claude Code and
Codex, in a plain terminal, in Herdr, and (later) in T3 Code.

## Overview

```
Notion task (notes, emails, meetings)
        │
        │  /prepare-task <url>      reads the evidence, asks you the design
        ▼                           questions, writes briefs and sub-tasks
Prepared task: brief, or container with sub-tasks (Blocked by → frontier)
        │
        │  /task <url> [selection]  gate → build → review → commit, per item
        ▼
Local commits on develop  +  run file (.task-runs/)  +  Notion comments
        │
        │  you: check the manual tests, answer the push question
        ▼
Pushed to origin/develop, tasks in "to review"; you set done
```

| Skill | Reads | Writes |
|---|---|---|
| `prepare-task` | the task, its parent, Project and every linked Note | after your approval: the briefs, the sub-tasks (backlog), the parent body |
| `task` | the briefs, the code | code and tests, one local commit per item, the run file, Notion status and one comment per item |
| `review-code` | a change set, optionally a spec | nothing but a report (an HTML file when it is long) |

## The Notion model in brief

- **Projects**, **Tasks** and **Notes** are three databases. A task is either a
  **leaf** (one brief) or a **container** whose sub-tasks carry the briefs.
  Sub-tasks have no Project and no Notes; they stay off the project board.
- Each sub-task starts with **Blocked by**: the siblings that must exist before
  it can be built. The **frontier** is every sub-task whose blockers are done.
- **Status flow:** backlog → in progress (`/task` starts it) → **to review**
  (`/task` committed it) → done (you, after checking) → deployment states.

`/task` sets "to review" only if that option exists in the Tasks database's
Status property. Add it there once; until then, items stay in progress and the
report says so.

## Using `/task`

| You type | What happens |
|---|---|
| `/task <url>` | A leaf: built as one item. A container: lists its sub-tasks (frontier first) and asks which. |
| `/task <url> all` | Every sub-task not yet done, frontier first. |
| `/task <url> 2,4` | Sub-tasks 2 and 4 of the list. |
| `/task <url> the admin and the import` | The sub-tasks you describe. |
| `/task <url1> <url2>` | Several tasks, in that order. |
| `/task <url> only the admin part` | One task; the text narrows or adds to its brief and is recorded as a decision. |
| `/task add a "Spécialité" column to the teacher list` | No Notion: the text is the brief. Nothing is written to Notion. |
| `/task resume` | Continues the newest unfinished run. |

In Codex, type `$task` instead of `/task`.

Add `plan first` anywhere to get a plan for every item, or `no plan` to skip
plans. Open questions and destructive data changes are still asked.

`/task` runs on `develop` or a feature branch. It refuses `main`, `master` and
`staging`, because those deploy.

## When the agent stops for you

**The preflight, at the start.** Each item is classified after the agent has
read the code:

- **go:** small and low risk. Built without a plan; the agent says why in one
  line.
- **plan:** any of these triggers:
  - an open question in the brief;
  - a migration or data change;
  - a new dependency;
  - auth, policies or roles;
  - mail, notifications or external APIs;
  - config, `.env`, queues, the scheduler, deploy or build scripts;
  - more than about six files, or more than one area;
  - adapting a reference in ways the brief doesn't state.

If any item needs a plan, or any question is open, you get **one** message for
the whole run: the plans, a line per go item, and every question. Answer once;
the rest of the run is meant to proceed without you. A run of go items only
starts straight away.

**During the run**, an item is **blocked** when the builder hits a decision the
brief doesn't make, the item turns out riskier than its gate, a check keeps
failing, or a review raises a judgment call. A blocked item:

- gets its question in the run file and as a Notion comment;
- has its partial work set aside in a named `git stash`;
- doesn't stop the run: items that don't depend on it carry on.

**At the end**, you get the report and one question: push to `origin/develop`?
Nothing is pushed without your yes.

## Reviews

| When | Review | Cost |
|---|---|---|
| Each go item | The builder's own check: tests and checks green, every criterion with evidence | no extra agent |
| Each plan item, before its commit | `review-code --quick`: one reviewer for correctness and spec | 1 subagent |
| End of the run | Full `review-code` over the run's commits, against the run file | by the other model, or 4 lanes |

The end-of-run review runs in **the other model** when its CLI works: Claude
builds and Codex reviews, or the reverse. Clear corrections get one fix commit;
judgment calls come to you in the report. There is no second review round
unless you ask for one.

`review-code` on its own:

```
/review-code                         uncommitted changes, else the last commit
/review-code 3                       the last 3 commits
/review-code a1b2c3d                 one commit
/review-code develop..feature        a range
/review-code feature-branch          a branch against its fork point
/review-code app/Models/Teacher.php  files, whole
… --spec <notion-url>                also check against a brief
… --spec .task-runs/<file>.md#2      against item 2 of a run file
… --quick                            one combined reviewer instead of the lanes
```

A review by the other model, by hand:

```bash
# from a terminal or from Claude: Codex reviews
codex exec -s read-only '$review-code 3 --spec .task-runs/<file>.md'

# from a terminal or from Codex: Claude reviews
claude -p --permission-mode plan '/review-code 3 --spec .task-runs/<file>.md'
```

## Following a run

- **The session itself:** the agent asks there when it needs you. The Stop and
  Notification sounds, Herdr's pane state and Claude's push notifications tell
  you when it does.
- **The run file:** `.task-runs/<date>-<slug>.md` in the project. It holds:
  - the items, with their gate and state (pending, building, reviewing,
    committed, blocked);
  - your decisions;
  - each item's brief, plan, build report and review.

  It's ignored through `.git/info/exclude`, so it is never committed and no
  `.gitignore` changes.
- **Git:** one commit per item. Notion items carry a `Task: <url>` trailer:
  `git log --grep "Task:"`.
- **Notion:** the board shows the status. Each item's page has a comment with
  its commit and what to test, or the question that blocks it.
- **Interrupted?** `/task resume` reads the run file, checks it against `git
  log`, and carries on.

## Environments

| Where | Notes |
|---|---|
| Claude Code in a terminal | Builders and reviewers are subagents. |
| Codex in a terminal | Same, with Codex's subagents. Codex reads Notion through the same hosted Notion MCP as Claude, added by `plugins.sh`, which also starts the Notion login in the browser (once per machine; `codex mcp login notion` redoes it). |
| Herdr | Nothing Herdr-specific: run `/task` in a pane. Herdr still shows each agent's state. Its own skill remains for when you ask for Herdr by name. |
| T3 Code (later) | `/task` runs as a provider skill. T3 runs one skill per message, which `/task` respects. |

## Later: parallel work with worktrees

Runs are serial today: one project, one branch, one run at a time. That avoids
two agents fighting over the same migrations and test database. Worktrees make
parallel runs possible once [Worktrunk](https://github.com/max-sixty/worktrunk)
works on both machines. It needs Git 2.43 or newer, and the Mac ships 2.39.

The plan for then:

- **One worktree per top-level task**, not per sub-task. Sub-tasks build on each
  other and would collide on migrations.
- `wt switch -c task/<slug>` from `develop`, then run `/task` inside the
  worktree.
- When the run is done: `wt merge develop --no-squash`. That is a local rebase
  and fast-forward into `develop`, with no PR and no push. The push question
  stays yours.
- **A `pre-start` hook in the project's `.config/wt.toml`** prepares each
  worktree so the site can be checked in the browser and tested on its own
  database:
  - `composer install` and `npm ci`;
  - `.env` copied, with its own `APP_URL` and database;
  - `valet link` or `lerd link`;
  - migrate and seed.

  T3 Code's `t3.json` (`runOnWorktreeCreate`) can call the same script.
- Run files already suit this: each run owns one file, and `info/exclude` is
  shared by all worktrees.
- Revisit then whether a clean run may push without asking.

## Quick reference

| Command | Does |
|---|---|
| `/prepare-task <url>` | Briefs and sub-tasks from the Notes, after your approval |
| `/task <url>` | Build a task, or choose sub-tasks of a container |
| `/task <url> all` · `2,4` · `<description>` | Build those sub-tasks |
| `/task <url1> <url2>` | Build several tasks in a row |
| `/task <text>` | Build a change described in free text |
| `/task … plan first` · `no plan` | Force or skip plans |
| `/task resume` | Continue an interrupted run |
| `/review-code [target] [--spec …] [--quick]` | Read-only review |
| `git log --grep "Task:"` | Commits made by `/task` for Notion items |
