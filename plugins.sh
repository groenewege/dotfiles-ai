#!/usr/bin/env bash
# Add the Claude Code plugin marketplaces and plugins, and the Codex MCP
# servers, listed in plugins/. Only adds what is missing; never removes or
# updates anything.
set -euo pipefail

AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

ok() { printf '  \033[32m✓\033[0m %s\n' "$*"; }

# Print the entries of a list file: one per line, '#' starts a comment.
list_from() {
  [[ -f $1 ]] || return 0
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e 's/^[[:space:]]*//' "$1" | grep -v '^$' || true
}

# Codex MCP servers, first so that a missing claude doesn't skip them. For an
# OAuth server, `codex mcp add` starts the browser login itself; the token is
# per machine. If that login was skipped: `codex mcp login <name>`.
if command -v codex >/dev/null; then
  while read -r name url; do
    if codex mcp get "$name" >/dev/null 2>&1; then
      ok "Codex MCP server already added: $name"
    else
      codex mcp add "$name" --url "$url"
      ok "Codex MCP server added: $name (not logged in? codex mcp login $name)"
    fi
  done < <(list_from "$AI_DIR/plugins/codex-mcp-servers.txt")
else
  echo "codex not found; skipping Codex MCP servers" >&2
fi

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
