#!/usr/bin/env bash
set -Eeuo pipefail
NAMESPACE="${1:-nvidia}"
MODEL="${2:-nemotron-3-super}"
BASE_DIR="${LIVEBENCH_HOME:-$HOME/livebench}"
ROOT="$BASE_DIR/state/live_bench/coding"

for TASK in LCB_generation coding_completion; do
  SRC="$ROOT/$TASK/model_answer/$NAMESPACE/$MODEL.jsonl"
  DST="$ROOT/$TASK/model_answer/$MODEL.jsonl"
  [[ -f "$SRC" ]] || { echo "ERROR: missing $SRC" >&2; exit 1; }
  jq -c --arg model "$MODEL" '.model_id = $model' "$SRC" > "$DST"
  echo "$TASK: $(wc -l < "$DST") answers -> $DST"
done
