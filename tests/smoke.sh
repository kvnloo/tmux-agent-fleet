#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
socket_name="agent-fleet-test-$$"
unset TMUX TMUX_PANE
cleanup() { TMUX= tmux -L "$socket_name" kill-server 2>/dev/null || true; }
trap cleanup EXIT

# Use bash so the smoke test does not require the user's interactive shell.
tmux -L "$socket_name" -f /dev/null new-session -d -s demo -c "$root" bash
socket=$(tmux -L "$socket_name" display-message -p '#{socket_path}')
server_pid=$(tmux -L "$socket_name" display-message -p '#{pid}')
export TMUX="$socket,$server_pid,0"

rows=$(AGENT_FLEET_LIST_ONLY=1 "$root/scripts/fleet.sh")
[[ $rows == *$'demo:'* && $rows == *'tmux-agent-fleet'* ]] || {
  printf 'expected isolated demo row, got:\n%s\n' "$rows" >&2
  exit 1
}

TMUX= tmux -L "$socket_name" run-shell "$root/agent-fleet.tmux"
sleep 0.1
binding=$(TMUX= tmux -L "$socket_name" list-keys -T prefix)
[[ $binding == *'display-popup'* && $binding == *'scripts/fleet.sh'* ]] || {
  printf 'unexpected prefix-f binding: %s\n' "$binding" >&2
  exit 1
}

printf 'ok: discovery row and prefix-f TPM binding\n'
