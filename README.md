# tmux-agent-fleet

A zero-daemon command palette for every coding agent in tmux.

`tmux-agent-fleet` turns `prefix + f` into one fast, searchable view of Claude Code, Codex, OpenCode, Gemini, Kimi, Grok, Oh My Pi, Pi, Fable, ordinary shells, and optional Agent Deck sessions. Select a row to jump to the exact pane; keep the live preview open to monitor work without rearranging your terminal.


## Why this exists

Agent sidebars are excellent when you want permanent telemetry. Fleet managers are excellent when they own every session. This plugin takes a smaller path:

- **No hooks or daemon required** — discovers live panes from tmux process metadata.
- **Harness-neutral** — one switcher for multiple coding CLIs instead of one vendor.
- **Non-invasive** — no pane injection, auto-renaming, worktree ownership, or session migration.
- **Theme-aware** — consumes the current pywal palette when available and has a readable fallback.
- **Composable** — optionally merges Agent Deck-managed sessions into the same list.
- **Private by construction** — local tmux metadata and a local pane preview; no network service.

The tradeoff is deliberate: without harness hooks, the built-in state marker means tmux pane activity, not a vendor-specific semantic state such as “waiting for permission.”

## Requirements

- tmux 3.2+
- [fzf](https://github.com/junegunn/fzf)
- Bash 4+
- `jq` only when using the optional Agent Deck adapter

## Install

### TPM

```tmux
set -g @plugin 'kvnloo/tmux-agent-fleet'
```

Reload tmux, then press `prefix + I`. Open the dashboard with `prefix + f`.

### Manual

```bash
git clone https://github.com/kvnloo/tmux-agent-fleet.git ~/.tmux/plugins/tmux-agent-fleet
```

Then in `~/.tmux.conf`:

```tmux
run-shell ~/.tmux/plugins/tmux-agent-fleet/agent-fleet.tmux
```

Reload the config (`prefix + r` if bound, or `tmux source-file ~/.tmux.conf`).

## Configuration

Configure options **before** the TPM plugin declaration (or before `run-shell` for a manual install). A full annotated copy lives in [`example.tmux.conf`](./example.tmux.conf).

```tmux
# Binding and built-in tmux popup geometry
set -g @agent-fleet-key 'f'
set -g @agent-fleet-width '96%'
set -g @agent-fleet-height '92%'

set -g @plugin 'kvnloo/tmux-agent-fleet'
```

Disable the automatic binding with:

```tmux
set -g @agent-fleet-key 'none'
```

### External floating terminal

Compositors can render the dashboard as a native floating window instead of a tmux popup. Set a launch command; tmux formats such as `#{pane_current_path}` and `#{client_tty}` are expanded when the binding runs.

```tmux
set -g @agent-fleet-launch-command \
  '$HOME/.local/bin/agent-fleet-popup "#{pane_current_path}" "#{client_tty}"'
```

The external launcher should start `~/.tmux/plugins/tmux-agent-fleet/scripts/fleet.sh`. Export `TMUX_AGENT_FLEET_CLIENT=#{client_tty}` so selection switches the client that opened the dashboard.

### Palette

By default the plugin sources `~/.cache/wal/colors.sh`. Override it for another compatible palette:

```bash
export AGENT_FLEET_PALETTE="$HOME/.cache/my-theme/colors.sh"
```

No palette is required; Tokyo Night-inspired fallback colors are built in.

## Controls

| Key | Action |
| --- | --- |
| `j` / `k`, arrows | Move through panes |
| `Enter` | Jump to selected pane or attach selected Agent Deck session |
| `Esc` | Close without changing focus |
| Type | Fuzzy-filter harness, project, location, or task title |

## Detection

Built-in labels cover Claude Code, Codex, OpenCode, Gemini, Kimi Code, Grok, Oh My Pi, Pi, and Fable. Other foreground commands still appear under their process name, so the dashboard remains useful for REPLs, servers, and ordinary shells.

Oh My Pi can run as `bun`; the plugin identifies it from its child command instead of presenting a generic runtime label.

## Agent Deck adapter

When both `agent-deck` and `jq` are available, managed Agent Deck sessions are appended automatically. Selecting one attaches it in place. Nothing changes when Agent Deck is absent.

## Scope

This plugin is a switcher and monitor, not an orchestrator. It intentionally does not:

- read harness transcripts outside the preview you explicitly open;
- install hooks into coding agents;
- create or delete worktrees;
- rename sessions automatically;
- run a background collector;
- send telemetry.

## Testing

With `tmux` and `fzf` on `PATH`:

```bash
./tests/smoke.sh
```

The smoke test starts an isolated tmux server (private socket), checks pane discovery, and verifies the default `prefix + f` binding loads from `agent-fleet.tmux`.

## Versioning

Tagged releases follow [SemVer](https://semver.org/) when published (for example `v0.1.0`). Until the first tag, install from `main` via TPM or clone as shown above. Prefer a release tag for production configs once available:

```tmux
set -g @plugin 'kvnloo/tmux-agent-fleet'
# or pin: set -g @plugin 'kvnloo/tmux-agent-fleet#v0.1.0'
```

## License

[MIT](./LICENSE) © Kevin Loo
