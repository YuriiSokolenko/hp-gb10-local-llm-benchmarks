#!/usr/bin/env bash
set -Eeuo pipefail
BASE_DIR="${LIVEBENCH_HOME:-$HOME/livebench}"

cat <<'WARN'
WARNING: this deletes ALL local LiveBench Coding answers and judgments
for every model in the persistent state directory.
Use it only when intentionally starting a completely clean comparison.
WARN

read -r -p "Type RESET to continue: " CONFIRM
[[ "$CONFIRM" == "RESET" ]] || exit 1

find "$BASE_DIR/state/live_bench/coding" \
  -type d \( -name model_answer -o -name model_judgment \) \
  -prune -exec rm -rf {} +

rm -f "$BASE_DIR/results/all_groups.csv" "$BASE_DIR/results/all_tasks.csv"
cd "$BASE_DIR"
./run-coding.sh all
