# dotfiles-ai

My instructions, skills and commands for Claude Code and Codex, shared by my
Mac ([dotfiles-mac](https://github.com/groenewege/dotfiles-mac)) and my Omarchy
laptop ([dotfiles-omarchy](https://github.com/groenewege/dotfiles-omarchy)).
Both clone this repo next to their own and run its `install.sh`.

## Layout

```
AGENTS.md            → ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md
skills/<name>/       → ~/.claude/skills/<name> and ~/.codex/skills/<name>
skills-claude/       Claude-only variants → ~/.claude/skills/
skills-codex/        Codex-only variants  → ~/.codex/skills/
commands/<name>.md   Claude Code slash commands → ~/.claude/commands/
docs/                how my workflows fit together (not linked anywhere)
plugins/             Claude plugins and Codex MCP servers, added by plugins.sh
install.sh           link everything (--dry-run to preview)
plugins.sh           add missing Claude plugins and Codex MCP servers
adopt.sh <name>      move a skill an agent created into this repo
orb/laravel/          Amp orb setup template for Laravel projects (see its README)
```

Every link points into this repo, so editing `~/.claude/skills/<name>/SKILL.md`
edits the repo. Whatever was in the way the first time is moved to
`~/.dotfiles-backup/<timestamp>/`. Skills installed by other tools (herdr, lerd,
Omarchy, claude.ai's `synced` folder) are left alone.

## Task workflow

Client work goes from a Notion task to commits on `develop` through three
skills: `/prepare-task` writes the briefs, `/task` builds them (one commit per
step, asking only when a change is risky), and `/review-code` reviews. How they
fit together, every option, and the plan for parallel work with worktrees:
[docs/task-workflow.md](docs/task-workflow.md).

## Install

```bash
git clone https://github.com/groenewege/dotfiles-ai.git ~/Code/dotfiles-ai
~/Code/dotfiles-ai/install.sh --dry-run   # preview
~/Code/dotfiles-ai/install.sh
~/Code/dotfiles-ai/plugins.sh             # Claude plugins, Codex MCP servers
```

The dotfiles repos of both machines do this for you.

## Amp orbs

Amp reads `~/.claude/skills`, so in an Amp orb the project's `.agents/setup`
(copied from [orb/laravel](orb/laravel/README.md)) clones this repo to
`~/dotfiles-ai`, runs `install.sh`, and writes `AGENTS.md` to
`/home/user/workspace/AGENTS.md` with a short orb note on top. The orb's
`.agents/resume` pulls this repo on every wake, so pushed changes reach orbs
without a new snapshot. Notion comes from a personal remote MCP server named
`notion` in Amp settings.

## Keeping the machines in sync

| When… | Do this |
|---|---|
| I changed a skill, AGENTS.md or a command | commit and push in this repo |
| The other machine changed something | `git pull` here (Omarchy's `update.sh` does it) |
| A skill was added or removed in the repo | `./install.sh` after pulling |
| An agent created a new skill in `~/.claude/skills` | `./adopt.sh <name>`, then commit |

`install.sh` lists skill folders it doesn't manage, so a skill created by an
agent doesn't stay on one machine by accident.

## Editing a skill

1. **Pull first**, so you edit the latest version and avoid a merge conflict
   with the other machine: `git -C ~/Code/dotfiles-ai pull`.
2. **Edit** through `~/.claude/skills/<name>/` (or in this repo directly; it's
   the same file).
3. **Check what changed.** Agents edit skills too (e.g. folding upgrade
   learnings into `upgrade-laravel-*`), so a skill can change without you
   touching it:
   ```bash
   cd ~/Code/dotfiles-ai
   git status
   git diff
   ```
4. **Remove client details before committing.** Agent-written learnings tend
   to name the real app, client or server. Replace them with neutral examples
   (ACME, `example.test`).
5. **Commit and push**: `git commit -am "upgrade-laravel-13: …" && git push`.
6. **On the other machine**, `git pull` here (Omarchy's `update.sh` does it).
   An edited skill needs nothing more; run `./install.sh` only when a skill
   was added or removed.

This repo is public: keep client names, hostnames and tokens out of it.
Machine-specific settings (`~/.claude/settings.json`, Codex's `config.toml`)
stay in each machine's own dotfiles.
