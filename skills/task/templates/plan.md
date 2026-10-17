# The preflight and its plans

The run's one up-front review point, sent when any item is a plan item or any
question is open. The reviewer checks three things: **is this the right work,
does it fit the codebase, what will it break.** Everything the run will need from
the human is asked here, so the rest of the run can proceed without them.

## The preflight message

One message for the whole run. A run of one plan item is just its plan
(below), with no Run section.

```markdown
## Run: <task or container title>
<url> · Branch: <branch> · Run file: .task-runs/<file>

| # | Item | Gate |
|---|---|---|
| 1 | enseignant : model + admin | plan: migration |
| 2 | enseignant : export | go: one Filament action and its test |
| 3 | enseignant : importation | plan: open question; after 1 |

Order: 1, 2, 3 (frontier first). Not in this run: <children left out, and why>.

<one plan per plan item, in run order, each in the shape below>

### Questions
Every open question of the run, numbered, each naming its item and what it
blocks, with a recommendation.

Approve to start the run, or tell me what to change. Go items need no approval
but can be overruled here.
```

## One plan

Same shape as native plan mode, sized to the item: a one-field change gets under
400 words, a multi-week feature gets what it needs. A section with nothing to say
is omitted, not filled with "None". Written in English, concrete about what the
user will see, terse about process.

```markdown
## <task title>
<task url> · Status: <current> · Project: <project> · Parent: <parent title or —>

### Context
Two or three sentences: the need (from GOAL), what already exists in the code, the
pattern being followed (one reference, named by file or commit).

### Approach
Acceptance criteria as a checklist, one line each, from REQUIREMENTS. Mark anything
that is your inference rather than the brief's text *(inferred)*. Product copy goes
inline, in French, in quotes: label "Spécialité", help "Visible pour les étudiants".

When the feature is modelled on X, follow with "Differs from X": adapt / drop / add
only. Keep is the default and is not listed; every drop names its reason.

Then anything surprising found in the code (a stale reference path and its
substitute, a mis-wired class, a convention the brief got wrong) and the inferred
choices the reviewer may want to overrule. Migration or data implications appear
here only when destructive, backfilling or deploy-order sensitive.

### Files
Compact list grouped by area, new vs edit. No per-file explanation.

### Verification
The tests to add or extend and the command that runs them, then two to four manual
checks with URL and role.

### Open questions
Only if any, and only in a single-item preflight; a run groups them under
Questions. Unresolved items from the brief, each with what it blocks; the rest
of the plan can proceed.

### Not doing
OUT OF SCOPE from the brief, plus anything you noticed and deliberately left alone.
```

## Then stop

Wait for explicit approval before touching application code. Write the approved
plans and the answers into the run file before the first build.

Ask about missing product decisions. Decide naming, file placement, test suite and
idiom yourself from the neighbouring code. A plan that ends in six questions about
naming has misread which decisions are the human's.
