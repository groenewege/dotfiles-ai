# Reading a prepared brief

A prepared task body has a `Blocked by` line (children only), then four sections,
each an `h3` followed by a divider:

```
**Blocked by:** <mentions of sibling sub-tasks>, or —
### GOAL
---
### REQUIREMENTS
---
### REFERENCES
---
### OUT OF SCOPE
---
```

`OUT OF SCOPE` is omitted when empty. A task missing GOAL **and** REQUIREMENTS has
not been prepared: recommend `/prepare-task` instead of guessing.

## Blocked by

The siblings whose work must exist before this one can start: the model before
its import, the form before the consultation of its answers. `—` means nothing
blocks it. A blocker counts as done when its Status is done, "to review" or a
later deployment state, or when it was committed earlier in the same run. A
child whose blocker is neither done nor part of the run cannot be built: say
which blocker and why it matters (code, tables or seed data this brief depends
on may not exist yet). Briefs written before this line existed do not have it:
read the dependencies from the brief text instead.

## GOAL

One or two sentences in product terms: who benefits and what becomes possible. If
an implementation choice does not serve the GOAL, it is probably the wrong choice,
however elegant.

## REQUIREMENTS

The acceptance criteria in prose, written by a developer who has read the client
correspondence. It mixes firm requirements ("the teacher selects one or two
sessions"), exact copy to use verbatim (quoted French, never translated or
paraphrased), concrete values (counts, dates, times, column names) and open
questions, usually at the end and sometimes phrased conversationally ("What do
you think?").

Read to the end. **An open question is a stop, not a hint.** If it affects what
you are about to build, raise it in the plan and let the human answer; do not pick
the option that looks more reasonable. It was written down because it was not
decided.

A line "Before implementing, give your opinion on …" is a genuine request for a
second opinion: answer it in the plan.

## REFERENCES

`@repo/relative/path` entries, sometimes with a note on what each one is for. They
are a map, not a fence: read them and their neighbours. A brief that names its
files does not need a fan-out to find them. How to treat them (stale paths,
conceptual references, pattern versus template, keep by default) is in the skill's
Phase D.

## OUT OF SCOPE

A hard boundary, placed deliberately because the evidence contained adjacent work
a reasonable implementer might absorb. Do not build it, and do not build "just the
groundwork for it". If it turns out to be genuinely required, that is a scope
change to raise, not to absorb.

## Free-text briefs

`/task <text>` has no Notion page: the text is the whole brief. Read it as
REQUIREMENTS with no REFERENCES. It is usually shorter and less careful than a
prepared brief, so:

- Find the code it is about yourself. A name it uses ("the teacher form", "the
  export button") is a conceptual reference: locate the implementation and
  record the paths in the run file.
- The GOAL is what the text asks for, in one sentence, written into the run file
  so the reviewer checks against the same thing.
- A question in the text, or two readings that would build different things, is
  an open question for the preflight. Wording, naming and placement are yours.
- A request that clearly holds several features is several items: propose the
  split in the preflight instead of building it as one.

Text given after a Notion URL (`/task <url> only the admin part`) narrows or
adds to that brief. Record it in the run file's Decisions. Where it contradicts
the brief, it wins, and the plan or the go line says so.

## When to go back to the Notes

The brief is the current specification; the Notes are the archive behind it.

| Trigger | What you are looking for |
|---|---|
| The brief is incomplete or self-contradictory | The original statement |
| You are about to depend on a decision | Who decided it, when, and whether it was revised |
| A note post-dates the brief | Whether it changes anything |
| User-facing copy is referenced but not quoted | The verbatim wording |

Note dates matter: a note newer than the task's last edit may carry a decision the
brief has not absorbed. Surface it rather than acting on it. Never re-read the
whole correspondence by default: it is long, in French, full of abandoned
proposals, and treating it as authoritative undoes the preparation step.
