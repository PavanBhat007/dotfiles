# Repo-Scoped Codex Setup

This project is configured so Codex uses the repo-local `.codex/` directory instead of the default user-level `~/.codex/`.

That gives you a project-specific home for:

- `config.toml`
- custom MCP server definitions
- reusable skills under `.codex/skills/`
- local agent brief files under `.codex/agents/`
- Codex runtime state such as logs, memories, and sessions

## What Makes This Setup Work

The key piece is [`start-codex.sh`](./start-codex.sh). It:

1. resolves the project root
2. exports `CODEX_HOME="$PROJECT_ROOT/.codex"`
3. loads `.env` if present
4. starts `codex`

As long as Codex is launched through this script, it will read `./.codex/config.toml` and `./.codex/skills/` instead of your user-level Codex home.

## Current Layout

```text
.
├── .codex/
│   ├── config.toml
│   ├── agents/
│   ├── skills/
│   ├── log/
│   ├── memories/
│   ├── sessions/
│   ├── shell_snapshots/
│   └── tmp/
└── start-codex.sh
```

Only a few parts need to be created manually on a new machine:

- `.codex/config.toml`
- `.codex/skills/`
- `.codex/agents/`
- `start-codex.sh`
- `.env`
- optional repo-level `AGENTS.md` instructions if you want Codex to follow local agent-brief usage rules

The other `.codex/*` directories are runtime state and can be created automatically by Codex.

## Prerequisites

Install these first:

- Codex CLI
- Node.js and `npx`
- Git

If you want all MCPs in the current config to work, you also need:

- local MongoDB access or an updated MongoDB connection string
- Playwright-compatible system dependencies if the Playwright MCP is used
- Atlassian access for the Atlassian MCP

## Step-By-Step Setup On Another Machine

### 1. Clone the project

```bash
git clone <your-project-repo>
cd <your-project-directory>
```

### 2. Create the repo-local Codex home

```bash
mkdir -p .codex
```

### 3. Add the shared skills and agent briefs

This setup keeps both repos inside the project-local `.codex/` directory.

```bash
git clone git@github.com:Neurofin/skills.git .codex/skills
git clone git@github.com:Neurofin/agents.git .codex/agents
```

If SSH access is not configured, use HTTPS remotes instead.

### 4. Create `.env`

Put machine-local values in a shell-compatible `.env` at the project root.

For the current MongoDB MCP setup, add:

```bash
MDB_MCP_CONNECTION_STRING=mongodb://localhost:27017
```

The variable name matters here. The MongoDB MCP expects `MDB_MCP_CONNECTION_STRING`, so do not rename it to a generic Mongo URL key.

Change that value if your MongoDB server is elsewhere.

This is the preferred setup because `start-codex.sh` already sources `.env` before launching Codex, and it keeps machine-specific values out of `config.toml`.

### 5. Create `.codex/config.toml`

Copy the existing config from this project and update the machine-specific values.

Current example:

```toml
model = "gpt-5.4"
model_reasoning_effort = "medium"

[mcp_servers.mongodb]
command = "npx"
args = ["-y", "mongodb-mcp-server"]
env_vars = ["MDB_MCP_CONNECTION_STRING"]
startup_timeout_sec = 30

[mcp_servers.playwright]
command = "npx"
args = ["@playwright/mcp@latest"]

[mcp_servers.sequential-thinking]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-sequential-thinking"]

[mcp_servers.atlassian]
command = "npx"
args = ["-y", "mcp-remote", "https://mcp.atlassian.com/v1/sse"]
startup_timeout_sec = 30

[projects."/absolute/path/to/your/project"]
trust_level = "untrusted"

[notice.model_migrations]
"gpt-5.3-codex" = "gpt-5.4"
```

Update at least these values:

- change `[projects."/absolute/path/to/your/project"]` to the real absolute path on the new machine
- add or remove MCP servers based on what the new machine should support
- keep the MongoDB MCP env var name as `MDB_MCP_CONNECTION_STRING`
- keep `startup_timeout_sec = 30` on the MongoDB MCP so it has enough time to connect during startup

Do not commit real secrets into `config.toml`. Put machine-local secrets and connection strings in `.env` instead.

### 6. Add the launcher script

Create `start-codex.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CODEX_HOME="$PROJECT_ROOT/.codex"

if [[ -f "$PROJECT_ROOT/.env" ]]; then
  set -a
  source "$PROJECT_ROOT/.env"
  set +a
fi

exec codex "$@"
```

Make it executable:

```bash
chmod +x start-codex.sh
```

### 7. Add repo instructions for local agent briefs

Skills are picked up from `$CODEX_HOME/skills`, but the markdown files under `.codex/agents/` are just local reference briefs unless your project instructions tell Codex how to use them.

For that, keep a project `AGENTS.md` with rules such as:

- when to open a brief from `.codex/agents/**`
- how to refer to those briefs in commentary
- a reminder not to treat them as native Codex subagents

This matters because the `.codex/agents/*.md` files are guidance files, not automatically spawned subagents.

### 8. Start Codex through the launcher

Always use:

```bash
./start-codex.sh
```

You can also pass normal Codex arguments:

```bash
./start-codex.sh --help
./start-codex.sh -c model_reasoning_effort=\"high\"
```

Do not start Codex directly with `codex` if you want this repo-local setup to be used.

## How To Verify It Is Using The Repo-Local Setup

After starting through `./start-codex.sh`, verify:

- Codex sees the skills under `.codex/skills/`
- Codex uses MCP servers defined in `.codex/config.toml`
- runtime files appear under `.codex/log/`, `.codex/sessions/`, or `.codex/tmp/`
- your user-level `~/.codex` is not the active home for this session

The simplest sanity check is:

```bash
echo "$CODEX_HOME"
```

It should resolve to:

```bash
<project-root>/.codex
```

## Updating Skills And Agent Briefs

Because `.codex/skills` and `.codex/agents` are separate git clones, update them independently:

```bash
git -C .codex/skills pull
git -C .codex/agents pull
```

If you want reproducible versions across teammates, pin specific commits or convert them to submodules instead of plain clones.

## Notes And Caveats

- The current `config.toml` contains a machine-specific project path. That must be changed on every new machine.
- `config.toml` is the right place for non-secret MCP wiring. Put secret or machine-local values in `.env`.
- The MongoDB MCP currently forwards the `connectionString` environment variable from `.env` via `env_vars = ["connectionString"]`.
- The `.codex/log`, `.codex/memories`, `.codex/sessions`, `.codex/shell_snapshots`, and `.codex/tmp` folders are operational data, not source-controlled setup.
- If someone launches `codex` directly without `CODEX_HOME` pointing at this repo, Codex will fall back to the user-level configuration.
