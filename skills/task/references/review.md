# Reviews in a run

Two review points: one per item before its commit, scaled to the item's gate,
and one over the whole run at the end. Reviewing every item in full and looping
on the findings is how a run burns hours. Review once in depth, at the end.

## Tiers

| When | Review | Subagents |
|---|---|---|
| A go item, before its commit | The builder's self-check: checks green, every criterion met with evidence. Read the staged diff against the brief yourself. | 0 |
| A plan item, before its commit | `review-code --quick --spec <run file>#<n>` (correctness and spec in one reviewer) | 1 |
| The last item to build, before its commit | The self-check, as for a go item, whatever its gate | 0 |
| End of run | Full `review-code <N> --spec <run file>` over the run's N commits, in the other model when possible | 0 to 4 |

The per-item review protects the items built after it from a broken base. The
last item to build (no selected item is still buildable after it) has none, and
the end-of-run review covers the same diff with every lane, so a quick review
before its commit only duplicates it. A run of a single item, go or plan, gets
one review: the end-of-run one. Skip it only when the human asked for no review.

`review-code` is a user-only skill, so a skill cannot invoke it by name. Read
its installed `SKILL.md` and follow it with the arguments above. In Claude
Code, that is `~/.claude/skills/review-code/` (read `${CLAUDE_SKILL_DIR}` in it as
that directory). In Codex, it is `~/.codex/skills/review-code/`. Its review stays
read-only: the fixer applies the corrections, not the reviewer.

`N` is the number of commits since the run's start SHA:
`git rev-list --count <start>..HEAD`.

## The other model

A review by a different model catches what the builder's model is blind to. It
runs through the other agent's CLI, which works the same in a terminal, Herdr or
T3 Code. Start it in the background; it takes minutes.

From Claude Code:

```bash
codex exec -s read-only -C "<repository root>" \
  -o "<repository root>/.task-runs/<run slug>-review.md" \
  '$review-code <N> --spec <run file>. Do not write the HTML report: return the full report as your final message.'
```

From Codex:

```bash
cd "<repository root>" && claude -p --permission-mode plan \
  '/review-code <N> --spec <run file>. Do not write the HTML report: return the full report as your final message.' \
  > ".task-runs/<run slug>-review.md"
```

From Codex, `claude` needs network access that Codex's default sandbox does not
grant: ask for the approval, or note that the session must run without the
sandbox.

Keep the single quotes: they stop the shell from expanding `$review-code`. The
spec is passed as the run file, so the reviewer needs no Notion access.

If the other CLI is missing, not logged in, or fails, run `review-code` in this
session instead, and say which model reviewed.

## Handling findings

Sort every finding as `review-code` reports it:

- **Clear correction** (a defect or a missing requirement with a concrete fix):
  send it to the fixer.
- **Judgment call:** before a commit, it blocks the item if it changes what the
  item does; otherwise record it for the final report. At the end of the run,
  it goes to the human.
- **False positive:** record why in the run file and move on.
- **Worth a look** (a suspicion below `review-code`'s evidence bar): check the
  cited code yourself. Promote it to a clear correction only when you can state
  the concrete failure and the fix is small and inside the item, and record the
  reason in the run file. Otherwise, record it for the final report.

One fixer round answers the review. A second review of the same change happens
only when the human asks for it.
