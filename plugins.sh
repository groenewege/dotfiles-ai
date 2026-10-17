#!/usr/bin/env bash
# Add the Claude Code plugin marketplaces and install the plugins listed in
# plugins/. Only adds what is missing; never removes or updates anything.
set -euo pipefail

AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

ok() { printf '  \033[32m✓\033[0m %s\n' "$*"; }

# Print the entries of a list file: one per line, '#' starts a comment.
list_from() {
  [[ -f $1 ]] || return 0
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e 's/^[[:space:]]*//' "$1" | grep -v '^$' || true
}

command -v claude >/dev/null || { echo "claude not found" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq not found" >&2; exit 1; }

known=$(claude plugin marketplace list --json | jq -r '.[].repo // empty')
while IFS= read -r repo; do
  if grep -qxF "$repo" <<<"$known"; then
    ok "marketplace already added: $repo"
  else
    claude plugin marketplace add "$repo"
  fi
done < <(list_from "$AI_DIR/plugins/claude-marketplaces.txt")

installed=$(claude plugin list --json | jq -r '.[] | .id // .pluginId // empty')
while IFS= read -r plugin; do
  if grep -qxF "$plugin" <<<"$installed"; then
    ok "plugin already installed: $plugin"
  else
    claude plugin install "$plugin"
  fi
done < <(list_from "$AI_DIR/plugins/claude-plugins.txt")
