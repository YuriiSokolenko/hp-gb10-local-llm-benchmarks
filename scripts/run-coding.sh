#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="${LIVEBENCH_HOME:-$HOME/livebench}"
IMAGE_NAME="${LIVEBENCH_IMAGE:-n150/livebench:latest}"
API_BASE="${LIVEBENCH_API_BASE:-http://192.168.8.210:3009/v1}"

PARALLEL_REQUESTS="${LIVEBENCH_PARALLEL:-4}"
MAX_TOKENS="${LIVEBENCH_MAX_TOKENS:-32768}"
TEMPERATURE="${LIVEBENCH_TEMPERATURE:-1.0}"
RELEASE="${LIVEBENCH_RELEASE:-2024-11-25}"

COUNT="${1:-10}"
API_MODEL_NAME="${2:-}"

if docker info >/dev/null 2>&1; then
    DOCKER="docker"
elif sudo docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
else
    echo "ERROR: Docker daemon is not available." >&2
    exit 1
fi

mkdir -p "$BASE_DIR/config" "$BASE_DIR/state" "$BASE_DIR/results" "$BASE_DIR/hf-cache"

echo "Endpoint: $API_BASE"

if [[ -z "$API_MODEL_NAME" ]]; then
    echo "Detecting currently loaded model..."
    MODELS_JSON="$(curl -fsS --connect-timeout 5 "$API_BASE/models")" || {
        echo "ERROR: Cannot reach $API_BASE/models" >&2
        exit 1
    }

    API_MODEL_NAME="$(printf '%s' "$MODELS_JSON" | python3 -c '
import json, sys
data = json.load(sys.stdin)
models = data.get("data", [])
if models:
    print(models[0]["id"])
')"
fi

if [[ -z "$API_MODEL_NAME" ]]; then
    echo "ERROR: No model detected." >&2
    exit 1
fi

LOWER_API_MODEL="$(printf '%s' "$API_MODEL_NAME" | tr '[:upper:]' '[:lower:]')"
BENCH_MODEL_NAME="${LOWER_API_MODEL##*/}"
SAFE_MODEL="$(printf '%s' "$BENCH_MODEL_NAME" | tr '/: ' '___')"
CONFIG_FILE="$BASE_DIR/config/${SAFE_MODEL}.yaml"

PROFILE="Generic"
REASONING_LABEL="default"
TOP_P="default"
TOP_K="default"
MIN_P="default"
FORCE_NONEMPTY_LABEL="default"

if [[ "$LOWER_API_MODEL" == *laguna* ]]; then
    PROFILE="Laguna"
    REASONING_LABEL="thinking"
    TOP_P="1.0"
    TOP_K="20"
    MIN_P="0.0"

    cat > "$CONFIG_FILE" <<EOF
display_name: "${BENCH_MODEL_NAME}"

api_name:
  openai: "${API_MODEL_NAME}"

default_provider: openai

api_kwargs:
  openai:
    top_p: 1.0
    extra_body:
      top_k: 20
      min_p: 0.0
EOF

elif [[ "$LOWER_API_MODEL" == *nemotron* ]]; then
    PROFILE="Nemotron"
    REASONING_LABEL="thinking"
    TOP_P="0.95"
    FORCE_NONEMPTY_LABEL="true"

    cat > "$CONFIG_FILE" <<EOF
display_name: "${BENCH_MODEL_NAME}"

api_name:
  openai: "${API_MODEL_NAME}"

default_provider: openai

api_kwargs:
  openai:
    top_p: 0.95
    extra_body:
      chat_template_kwargs:
        enable_thinking: true
        force_nonempty_content: true
EOF

elif [[ "$LOWER_API_MODEL" == *qwen* ]]; then
    PROFILE="Qwen"
    REASONING_LABEL="xhigh"
    TOP_P="0.95"
    TOP_K="20"

    cat > "$CONFIG_FILE" <<EOF
display_name: "${BENCH_MODEL_NAME}"

api_name:
  openai: "${API_MODEL_NAME}"

default_provider: openai

api_kwargs:
  openai:
    top_p: 0.95
    extra_body:
      top_k: 20
      chat_template_kwargs:
        reasoning_effort: xhigh
EOF

else
    cat > "$CONFIG_FILE" <<EOF
display_name: "${BENCH_MODEL_NAME}"

api_name:
  openai: "${API_MODEL_NAME}"

default_provider: openai
EOF
fi

QUESTION_ARGS=()
if [[ "$COUNT" != "all" ]]; then
    if ! [[ "$COUNT" =~ ^[0-9]+$ ]]; then
        echo "ERROR: First argument must be a number or 'all'." >&2
        exit 1
    fi
    QUESTION_ARGS=(--question-begin 0 --question-end "$COUNT")
fi

echo
echo "======================================================"
echo " LiveBench Coding"
echo "======================================================"
echo "API model:          $API_MODEL_NAME"
echo "Benchmark model:    $BENCH_MODEL_NAME"
echo "Profile:            $PROFILE"
echo "Endpoint:           $API_BASE"
echo "Release:            $RELEASE"
echo "Questions/task:     $COUNT"
echo "Parallel requests:  $PARALLEL_REQUESTS"
echo "Max tokens:         $MAX_TOKENS"
echo "Reasoning:          $REASONING_LABEL"
echo "Temperature:        $TEMPERATURE"
echo "Top P:              $TOP_P"
echo "Top K:              $TOP_K"
echo "Min P:              $MIN_P"
echo "Force nonempty:     $FORCE_NONEMPTY_LABEL"
echo "Timeout:            7200 sec"
echo "Streaming:          disabled"
echo "Resume:             enabled"
echo "======================================================"
echo

"$DOCKER" run --rm -it \
    --name "livebench-${SAFE_MODEL}" \
    -v "$BASE_DIR/state:/opt/LiveBench/livebench/data" \
    -v "$BASE_DIR/results:/results" \
    -v "$BASE_DIR/hf-cache:/root/.cache/huggingface" \
    -v "$CONFIG_FILE:/opt/LiveBench/livebench/model/model_configs/local.yaml:ro" \
    "$IMAGE_NAME" \
    bash -lc '
        set -e
        cd /opt/LiveBench/livebench
        python run_livebench.py \
            --model "'"$BENCH_MODEL_NAME"'" \
            --model-provider-override openai \
            --api-base "'"$API_BASE"'" \
            --api-key EMPTY \
            --bench-name live_bench/coding \
            --livebench-release-option "'"$RELEASE"'" \
            --parallel-requests "'"$PARALLEL_REQUESTS"'" \
            --max-tokens "'"$MAX_TOKENS"'" \
            --force-temperature "'"$TEMPERATURE"'" \
            --no-incremental-grading \
            --resume \
            '"${QUESTION_ARGS[*]}"'
        cp -f all_groups.csv /results/ 2>/dev/null || true
        cp -f all_tasks.csv /results/ 2>/dev/null || true
    '

echo
echo "Persistent benchmark data: $BASE_DIR/state"
echo "Summary CSV:               $BASE_DIR/results"
