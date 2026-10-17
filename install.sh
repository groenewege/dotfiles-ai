#!/usr/bin/env bash
# Link the shared agent instructions, skills and commands into ~/.claude and
# ~/.codex. Safe to run again at any time; --dry-run shows what would change.
#
#   AGENTS.md          → ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md
#   skills/<name>      → ~/.claude/skills/<name> and ~/.codex/skills/<name>
#   skills-claude/<n>  → ~/.claude/skills/<n>   (Claude-only variants)
#   skills-codex/<n>   → ~/.codex/skills/<n>    (Codex-only variants)
#   commands/<n>.md    → ~/.claude/commands/<n>.md
#
# Runs on macOS (bash 3.2) and Linux.
set -euo pipefail

AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"
DRY_RUN=0
[[ ${1:-} == --dry-run || ${1:-} == -n ]] && DRY_RUN=1

# Skills other tools install into the same folders; not ours to manage.
EXTERNAL_SKILLS=" herdr lerd synced "

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*" >&2; }
pretty() { local tilde='~'; printf '%s' "${1/#$HOME/$tilde}"; }

# Run a command, except with --dry-run (the messages still say what would happen).
run() {
  ((DRY_RUN)) || "$@"
}

# Move <target> into the backup dir, keeping its path under $HOME.
backup() {
  local target=$1 rel dest n=1
  rel=${target#"$HOME"/}
  dest="$BACKUP_DIR/$rel"
  while [[ -e $dest || -L $dest ]]; do dest="$BACKUP_DIR/$rel.$((n++))"; done
  run mkdir -p "$(dirname "$dest")"
  run mv "$target" "$dest"
  warn "backed up $(pretty "$target") to $(pretty "$dest")"
}

# Symlink <src> to <target>, backing up whatever was there before.
link() {
  local src=$1 target=$2
  if [[ -L $target && $(readlink -f "$target") == "$(readlink -f "$src")" ]]; then
    return 0
  fi
  if [[ -e $target || -L $target ]]; then
    backup "$target"
  fi
  run mkdir -p "$(dirname "$target")"
  run ln -s "$src" "$target"
  ok "linked $(pretty "$target")"
}

# Remove links in <dir> that point into this repo at something that no longer
# exists (a skill or command that was deleted or renamed).
prune() {
  local dir=$1 entry dest
  [[ -d $dir ]] || return 0
  for entry in "$dir"/*; do
    [[ -L $entry ]] || continue
    dest=$(readlink "$entry")
    [[ $dest == "$AI_DIR"/* && ! -e $dest ]] || continue
    run rm "$entry"
    ok "removed stale link $(pretty "$entry")"
  done
}

# List folders in <dir> that are neither ours nor known to come from a tool,
# so a skill an agent created doesn't go unnoticed.
report_unmanaged() {
  local dir=$1 entry name
  [[ -d $dir ]] || return 0
  for entry in "$dir"/*; do
    [[ -e $entry ]] || continue
    name=$(basename "$entry")
    [[ $EXTERNAL_SKILLS == *" $name "* ]] && continue
    [[ -d $AI_DIR/skills/$name || -d $AI_DIR/skills-claude/$name || -d $AI_DIR/skills-codex/$name ]] && continue
    warn "$(pretty "$entry") is not in dotfiles-ai; keep it with: $AI_DIR/adopt.sh $name"
  done
}

if ((DRY_RUN)); then
  printf 'Dry run: these are the changes a real run would make.\n'
fi

link "$AI_DIR/AGENTS.md" "$HOME/.claude/CLAUDE.md"
link "$AI_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"

for skill in "$AI_DIR"/skills/*/; do
  [[ -d $skill ]] || continue
  name=$(basename "$skill")
  link "$AI_DIR/skills/$name" "$HOME/.claude/skills/$name"
  link "$AI_DIR/skills/$name" "$HOME/.codex/skills/$name"
done
for skill in "$AI_DIR"/skills-claude/*/; do
  [[ -d $skill ]] || continue
  name=$(basename "$skill")
  link "$AI_DIR/skills-claude/$name" "$HOME/.claude/skills/$name"
done
for skill in "$AI_DIR"/skills-codex/*/; do
  [[ -d $skill ]] || continue
  name=$(basename "$skill")
  link "$AI_DIR/skills-codex/$name" "$HOME/.codex/skills/$name"
done

for command in "$AI_DIR"/commands/*.md; do
  [[ -f $command ]] || continue
  link "$command" "$HOME/.claude/commands/$(basename "$command")"
done

prune "$HOME/.claude/skills"
prune "$HOME/.codex/skills"
prune "$HOME/.claude/commands"

report_unmanaged "$HOME/.claude/skills"
report_unmanaged "$HOME/.codex/skills"

ok "agent instructions, skills and commands linked"
