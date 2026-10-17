#!/usr/bin/env bash
# Move a skill that an agent created in ~/.claude/skills (or ~/.codex/skills)
# into this repo, then link it for both agents.
#
#   ./adopt.sh <name>           → skills/<name>         (Claude and Codex)
#   ./adopt.sh <name> --claude  → skills-claude/<name>  (Claude only)
#   ./adopt.sh <name> --codex   → skills-codex/<name>   (Codex only)
set -euo pipefail

AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
name=${1:?usage: adopt.sh <skill-name> [--claude|--codex]}
case ${2:-} in
  --claude) dest_dir=skills-claude ;;
  --codex) dest_dir=skills-codex ;;
  '') dest_dir=skills ;;
  *) echo "unknown option: $2" >&2; exit 1 ;;
esac

src=""
for candidate in "$HOME/.claude/skills/$name" "$HOME/.codex/skills/$name"; do
  if [[ -d $candidate && ! -L $candidate ]]; then
    src=$candidate
    break
  fi
done
[[ -n $src ]] || { echo "no unlinked skill folder named $name in ~/.claude/skills or ~/.codex/skills" >&2; exit 1; }
[[ -f $src/SKILL.md ]] || { echo "$src has no SKILL.md" >&2; exit 1; }

dest="$AI_DIR/$dest_dir/$name"
[[ -e $dest ]] && { echo "$dest already exists; merge by hand" >&2; exit 1; }

mkdir -p "$AI_DIR/$dest_dir"
mv "$src" "$dest"
echo "moved $src to $dest"

# A copy of the same skill in the other agent's folder gets backed up by install.sh.
"$AI_DIR/install.sh"
echo "Review it, then commit: git -C \"$AI_DIR\" add \"$dest_dir/$name\" && git -C \"$AI_DIR\" commit"
