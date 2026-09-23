#!/usr/bin/env bash
set -Eeuo pipefail
MODEL="${1:?Usage: $0 <benchmark-model-id>}"
BASE_DIR="${LIVEBENCH_HOME:-$HOME/livebench}"
IMAGE_NAME="${LIVEBENCH_IMAGE:-n150/livebench:latest}"
RELEASE="${LIVEBENCH_RELEASE:-2024-11-25}"

docker run --rm -it \
  -v "$BASE_DIR/state:/opt/LiveBench/livebench/data" \
  -v "$BASE_DIR/hf-cache:/root/.cache/huggingface" \
  -v "$BASE_DIR/results:/results" \
  "$IMAGE_NAME" \
  bash -lc '
    set -e
    cd /opt/LiveBench/livebench
    python gen_ground_truth_judgment.py \
      --question-source huggingface \
      --model "'"$MODEL"'" \
      --bench-name live_bench/coding \
      --resume \
      --livebench-release-option "'"$RELEASE"'"

    python show_livebench_result.py \
      --bench-name live_bench/coding \
      --question-source huggingface \
      --livebench-release-option "'"$RELEASE"'"

    cp -f all_groups.csv all_tasks.csv /results/

    echo
    echo "=== OVERALL ==="
    cat all_groups.csv
    echo
    echo "=== TASKS ==="
    cat all_tasks.csv
  '
