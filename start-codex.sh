#!/usr/bin/env bash
# Launch codex with project-specific config and environment.
set -euo pipefail

# Resolve project root from this script location.
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure Codex reads project-local configuration (./.codex/config.toml).
export CODEX_HOME="$PROJECT_ROOT/.codex"

# Load environment variables from .env if present.
# This expects a shell-compatible .env file.
if [[ -f "$PROJECT_ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$PROJECT_ROOT/.env"
  set +a
fi

exec codex "$@"
