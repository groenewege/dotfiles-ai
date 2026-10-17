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
plugins/             Claude Code marketplaces and plugins, installed by plugins.sh
install.sh           link everything (--dry-run to preview)
plugins.sh           add missing marketplaces and plugins
adopt.sh <name>      move a skill an agent created into this repo
```

Every link points into this repo, so editing `~/.claude/skills/<name>/SKILL.md`
edits the repo. Whatever was in the way the first time is moved to
`~/.dotfiles-backup/<timestamp>/`. Skills installed by other tools (herdr, lerd,
claude.ai's `synced` folder) are left alone.

## Install

```bash
git clone https://github.com/groenewege/dotfiles-ai.git ~/Code/dotfiles-ai
~/Code/dotfiles-ai/install.sh --dry-run   # preview
~/Code/dotfiles-ai/install.sh
~/Code/dotfiles-ai/plugins.sh             # optional: Claude Code plugins
```

The dotfiles repos of both machines do this for you.

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
