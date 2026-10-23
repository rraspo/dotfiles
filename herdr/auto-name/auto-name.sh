#!/usr/bin/env bash
# Give every unnamed herdr agent a name derived from its working directory
# (e.g. ~/projects/fonema -> fonema, a second one -> fonema-2).
# Idempotent: agents that already have a name, set by hand or earlier, are left alone.
set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
agents_json="$("$herdr" agent list)"

taken="$(jq -r '.result.agents[] | .name // empty' <<<"$agents_json")"

jq -r '.result.agents[] | select((.name // "") == "") | [.pane_id, (.cwd // .foreground_cwd // "")] | @tsv' <<<"$agents_json" |
while IFS=$'\t' read -r pane_id cwd; do
    [[ -n "$cwd" ]] || continue
    base="$(basename "$cwd" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_-' '-' | sed -E 's/-+/-/g; s/^[^a-z]+//; s/-+$//')"
    base="${base:0:29}"
    [[ -n "$base" ]] || base="agent"

    name="$base"
    suffix=2
    while grep -qxF "$name" <<<"$taken"; do
        name="${base}-${suffix}"
        suffix=$((suffix + 1))
    done

    if "$herdr" agent rename "$pane_id" "$name" >/dev/null; then
        taken+=$'\n'"$name"
    fi
done
