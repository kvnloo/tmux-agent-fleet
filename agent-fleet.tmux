#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
key=$(tmux show-option -gqv @agent-fleet-key)
key=${key:-f}
launch=$(tmux show-option -gqv @agent-fleet-launch-command)
width=$(tmux show-option -gqv @agent-fleet-width)
height=$(tmux show-option -gqv @agent-fleet-height)
width=${width:-96%}
height=${height:-92%}

if [[ $key != none ]]; then
  if [[ -n $launch ]]; then
    tmux bind-key "$key" run-shell -b "$launch"
  else
    tmux bind-key "$key" display-popup -E \
      -w "$width" -h "$height" -d '#{pane_current_path}' \
      "$root/scripts/fleet.sh"
  fi
fi
