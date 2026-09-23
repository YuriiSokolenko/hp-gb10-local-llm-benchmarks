#!/usr/bin/env bash
set -Eeuo pipefail
MODEL="${1:?Usage: $0 <benchmark-model-id>}"
BASE_DIR="${LIVEBENCH_HOME:-$HOME/livebench}"
ROOT="$BASE_DIR/state/live_bench/coding"

mapfile -t FILES < <(find "$ROOT" -type f -path "*/model_answer/${MODEL}.jsonl" -print)
if (( ${#FILES[@]} == 0 )); then
  echo "ERROR: no answer files found for model: $MODEL" >&2
  exit 1
fi

cat "${FILES[@]}" | jq -s '
{
  requests: length,
  first_tstamp: (map(.tstamp) | min),
  last_tstamp: (map(.tstamp) | max),
  wall_span_seconds: ((map(.tstamp) | max) - (map(.tstamp) | min)),
  sum_request_seconds: (map(.total_time_s // 0) | add),
  avg_request_seconds: ((map(.total_time_s // 0) | add) / length),
  input_tokens: (map(.total_input_tokens // 0) | add),
  output_tokens: (map(.total_output_tokens // 0) | add)
}'
