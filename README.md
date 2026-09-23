# Local Coding LLMs on an NVIDIA GB10 / DGX Spark-Class Computer

This benchmark tests large local coding LLMs on an **NVIDIA GB10 Grace Blackwell AI computer — the same core compute platform used by NVIDIA DGX Spark**.

The physical machine is an **HP ZGX Nano G1n AI Station** (HP product `CZ2V8UT#ABA`). It is HP's OEM implementation of the NVIDIA GB10 / DGX Spark-class platform: NVIDIA GB10 Grace Blackwell, 128 GB coherent unified memory, DGX OS, and a compact desktop form factor.

- NVIDIA DGX Spark: https://www.nvidia.com/en-us/products/workstations/dgx-spark/
- HP ZGX Nano G1n: https://www.hp.com/us-en/shop/pdp/hp-zgx-nano-g1n-ai-station-p-cz2v8ut-aba-1

### NVIDIA reference system vs. the HP system used here

> **Official manufacturer images — not AI-generated.**  
> Left: NVIDIA DGX Spark Founders Edition product image.  
> Right: HP's official product image for the HP ZGX Nano G1n.

<table>
  <tr>
    <td align="center" width="50%">
      <img src="https://vishalperipherals.com/cdn/shop/files/DGX-Spark.png?v=1769164576&width=1445" alt="NVIDIA DGX Spark Founders Edition" width="520">
    </td>
    <td align="center" width="50%">
      <img src="https://hp.widen.net/content/msaniswk8a/webp/msaniswk8a.png?color=ffffff00&dpi=72&h=430&w=573" alt="HP ZGX Nano G1n — official HP product image" width="520">
    </td>
  </tr>
  <tr>
    <td align="center"><strong>NVIDIA DGX Spark</strong><br><sub>Founders Edition product image</sub></td>
    <td align="center"><strong>HP ZGX Nano G1n</strong><br><sub>Exact OEM system family used for this benchmark</sub></td>
  </tr>
</table>

Official manufacturer websites:
- NVIDIA DGX Spark: https://www.nvidia.com/en-us/products/workstations/dgx-spark/
- HP ZGX Nano G1n: https://www.hp.com/us-en/shop/pdp/hp-zgx-nano-g1n-ai-station-p-cz2v8ut-aba-1


**Benchmark date:** September 2026  
**LiveBench release:** `2024-11-25`  
**LiveBench source commit:** `1263ee472f4b9ac3833c0d2f6ad50dd3747fd1df`  
**Questions:** 128 total (`78 LCB_generation + 50 coding_completion`)  
**Client concurrency:** 4  
**Max output:** 32,768 tokens/request  
**Benchmark client:** separate Intel N150 mini-PC  
**Inference computer:** HP ZGX Nano G1n / NVIDIA GB10 Grace Blackwell / 128 GB unified memory

> Scope: these are results for this exact LiveBench release, serving stack, quantization, request configuration, and hardware. They are not a universal ranking of the models.

For the complete read-only machine audit, model manifests, SHA-256 hashes, image digests, file inventory, and raw methodology notes, see **[docs/gb10-livebench-audit.md](docs/gb10-livebench-audit.md)**.

![Overall score](assets/overall-score.svg)

## Results

| Model | Backend | Quantization | Model size | Context | Overall | LCB_generation | coding_completion | Wall span |
|---|---|---|---:|---:|---:|---:|---:|---:|
| Qwen3.8-Flash-Next GGUF | llama.cpp | UD-Q4_K_XL | 103.688 GiB | 262,144 | **80.6** | 69.231 | **92.0** | 07:35:47.147 |
| Qwen3.8-Flash-Next NVFP4 | vLLM | ModelOpt NVFP4 + PLE | 108.029 GiB | 262,144 | **77.6** | 69.231 | 86.0 | **06:21:26.776** |
| Laguna S 2.1 GGUF | llama.cpp | UD-Q6_K_XL | 99.726 GiB | 204,800 | 67.0 | **82.051** | 52.0 | 08:56:05.703 |
| NVIDIA Nemotron 3 Super | vLLM | NVFP4 / `modelopt_mixed` | 74.802 GiB | 204,800 | 65.8 | 75.641 | 56.0 | 06:35:05.241 |

`Wall span` is `max(tstamp) - min(tstamp)` across the 128 saved answer records, not shell process start-to-exit time.

![Task breakdown](assets/task-breakdown.svg)

### What the scores show

- **Qwen GGUF had the highest overall Coding score: 80.6**, driven by a `coding_completion` score of 92.
- **Qwen NVFP4 scored 77.6** and had the shortest completed wall span: 06:21:26.776.
- **Laguna had the strongest generation-from-scratch score: 82.051**, but only 52 on completion.
- **Nemotron was also stronger than Qwen on LCB_generation (75.641 vs 69.231)**, but its completion score was only 56.
- The benchmark therefore exposes two different behaviors: Qwen is much stronger at completion, while Laguna and Nemotron are comparatively stronger at generation.

![Wall time](assets/wall-time.svg)

## Important: failures and max-token runs

The final score should be read together with the response-failure data:

| Model | API/error records | Max-token observations |
|---|---:|---:|
| Qwen NVFP4 | 15 | 20 JSON records at or above 32,768 output tokens; exact finish-reason truncation flag not found |
| Qwen GGUF | 14 | **14 server-log generations at exactly 32,768 tokens**; the corresponding JSON error records store zero usage |
| Laguna GGUF | **0** | **0** |
| Nemotron NVFP4 | **0** | 15 records exactly at 32,768 output tokens |

This is especially relevant for interpreting Qwen GGUF: the known 32,768-token response was not an isolated event. The llama.cpp server log recorded 14 such generations, matching the 14 LiveBench error/no-normal-message records.

## Hardware

### NVIDIA GB10 / DGX Spark-class inference computer

The benchmark is fundamentally a test of what the **NVIDIA GB10 platform** can do locally. The physical unit used is HP's implementation rather than an NVIDIA-branded DGX Spark.

| Component | Verified benchmark machine |
|---|---|
| Product | **HP ZGX Nano G1n AI Station** |
| HP product number | **CZ2V8UT#ABA** |
| Accelerator | **NVIDIA GB10** |
| CPU | **20-core Arm**: 10× Cortex-X925 + 10× Cortex-A725 |
| CPU architecture | `aarch64`, 1 socket, 20 cores, 1 thread/core |
| System memory | nominal **128 GB coherent unified memory** |
| Linux-visible RAM | **130,596,184,064 bytes / 121.63 GiB** |
| Swap | **16.00 GiB** |
| Storage | **4 TB NVMe**, model `ESL04TBTLCZ-27J4-TYN` |
| OS | **Ubuntu 24.04.5 LTS** |
| Kernel | `6.17.0-1018-nvidia` |
| NVIDIA driver | `580.159.03` |
| CUDA compatibility | `13.0` |
| Installed CUDA SDK | `13.0.3` |
| Docker | `29.2.1`, linux/arm64 |
| NVIDIA Container Toolkit | `1.20.0` |
| Benchmark API | OpenAI-compatible endpoint on port `3009` |

The audit-time **idle** sample was 39 °C, 5.59 W, and 208 MHz graphics clock. It is not benchmark telemetry.

### Benchmark client

LiveBench ran on a separate Intel N150 mini-PC:

| Item | Value |
|---|---|
| CPU | Intel N150, 4 cores / 4 threads |
| OS | Ubuntu 26.04 LTS |
| Kernel | `7.0.0-31-generic` |
| RAM | 15,985,524,736 bytes / 14.89 GiB |
| Docker | `29.5.3` |
| Route to GB10 host | Wi-Fi `wlo1` |
| Negotiated Wi-Fi link speed | not found |

Separating inference from the benchmark client avoided consuming additional GB10 memory for the LiveBench harness.

## Exact model provenance

| Benchmark model | Artifact repository | Revision | Weight bytes |
|---|---|---|---:|
| Qwen3.8-Flash-Next NVFP4 | `MagneticLab/Qwen3.8-Flash-Next-NVFP4` | `e30ead75503c0b734af6ec0614ef22089eee6bf3` | 115,995,354,872 |
| Qwen3.8-Flash-Next GGUF | `unsloth/Qwen3.8-Flash-Next-GGUF` | `38bb39ee97821de2c9009abb7e93950eec396e66` | 111,334,654,784 |
| Laguna S 2.1 GGUF | `unsloth/Laguna-S-2.1-GGUF` | `750f92f90cf54159c4d7a610cb7b3e74498e75c6` | 107,079,627,552 |
| NVIDIA Nemotron 3 Super NVFP4 | `nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4` | `ff433f5493e25d631c9f12b5d55c674229923d02` | 80,317,948,856 |

The Qwen NVFP4 artifact consists of 100 retained model shards plus 128 PLE sidecars. Its total active weight payload is 108.029 GiB. Exact shard sizes and SHA-256 manifests for all GGUF/Nemotron files are in the full audit.

## Inference stacks

### Qwen3.8-Flash-Next NVFP4 — vLLM

- Image: `vllm/vllm-openai:qwen38-flash-next`
- Image digest: `sha256:fc120ece0a388cc0aa1caad4a9f1cd92113484ab7ec2fd0efadd62585be05bf8`
- vLLM: `0.1.dev20073+g8e685d198`
- dtype: BF16
- quantization: `modelopt_fp4`
- KV allocation: 10 GiB fixed via `--kv-cache-memory-bytes 10737418240`
- `max_model_len=262144`
- `max_num_seqs=4`
- `max_num_batched_tokens=8192`
- prefix caching: enabled
- TP/PP/DP: 1/1/1

Exact effective server command:

```bash
vllm serve --model /model \
  --served-model-name Qwen3.8-Flash-Next-NVFP4 \
  --quantization modelopt_fp4 \
  --distributed-executor-backend mp \
  --tensor-parallel-size 1 \
  --kv-cache-memory-bytes 10737418240 \
  --max-num-seqs 4 \
  --max-model-len 262144 \
  --max-num-batched-tokens 8192 \
  --enable-prefix-caching \
  --no-enable-flashinfer-autotune \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3_xml \
  --reasoning-parser qwen3 \
  --host 0.0.0.0 --port 3009
```

### NVIDIA Nemotron 3 Super — vLLM

- Image: `vllm/vllm-openai:v0.27.1`
- Image digest: `sha256:0a51ea5b4ae2dc5d81890e5173f54203d2a3ae0cfffe51b8fd2afd4391bfd967`
- vLLM: `0.27.1`
- effective dtype: BF16
- quantization: `modelopt_mixed`
- KV cache: `fp8_e4m3`
- `max_model_len=204800` — **verified exact benchmark value**
- `max_num_seqs=4`
- prefix caching: false
- TP/PP/DP: 1/1/1
- MoE backend: `marlin`

Exact effective server command:

```bash
vllm serve --model /model \
  --served-model-name nvidia/nemotron-3-super \
  --host 0.0.0.0 --port 3009 \
  --async-scheduling \
  --dtype auto \
  --kv-cache-dtype fp8 \
  --tensor-parallel-size 1 \
  --pipeline-parallel-size 1 \
  --data-parallel-size 1 \
  --trust-remote-code \
  --gpu-memory-utilization 0.90 \
  --enable-chunked-prefill \
  --max-num-seqs 4 \
  --max-model-len 204800 \
  --moe-backend marlin \
  --mamba-ssm-cache-dtype float16 \
  --quantization fp4 \
  --reasoning-parser-plugin /app/super_v3_reasoning_parser.py \
  --reasoning-parser super_v3 \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3_coder
```

### Qwen GGUF and Laguna — llama.cpp

Both used:

- llama.cpp commit: `18a04f09c24616898792bcfaa17f3550bdc78912`
- version: `0.4.1-dev`, build 11043
- CUDA architecture 121 / `sm_121a`
- `GGML_CUDA=ON`
- `GGML_CUDA_FA=ON`
- `GGML_CUDA_GRAPHS=ON`
- 4 parallel slots
- `--gpu-layers 999`
- Flash Attention on
- q4_0 K/V cache
- continuous batching
- Jinja templates
- effective batch / ubatch: 2048 / 512
- threads / batch threads: 20 / 20

```bash
llama-server \
  --model FIRST_SHARD \
  --alias MODEL_ID \
  --host 0.0.0.0 --port 3009 \
  --parallel 4 \
  --kv-unified-per-slot CONTEXT \
  --cont-batching \
  --gpu-layers 999 \
  --flash-attn on \
  --cache-type-k q4_0 \
  --cache-type-v q4_0 \
  --jinja
```

| Model | Per-slot context | Total KV pool |
|---|---:|---:|
| Qwen GGUF | **262,144** | 1,048,576 |
| Laguna GGUF | **204,800** | 819,200 |

For Laguna, the earlier 262,144 attempt stopped during loading. The successful benchmark server log explicitly used 204,800 per slot.

## LiveBench environment

The client image is locally built as `n150/livebench:latest`.

| Item | Verified value |
|---|---|
| LiveBench repo | `https://github.com/LiveBench/LiveBench.git` |
| Commit | `1263ee472f4b9ac3833c0d2f6ad50dd3747fd1df` |
| Branch | `main` |
| Image ID | `sha256:0fc3818ba0ed91a5753f3f87a5c2ec7601031580c4659482f1ea95588aee8934` |
| Python | 3.10.21 |
| OpenAI package | 2.54.0 |
| LiteLLM | 1.102.0 |
| httpx | 0.28.1 |
| datasets | 5.0.1 |
| pandas | 2.2.3 |
| numpy | 2.2.6 |

One local source modification increased the request timeout:

```diff
-TIMEOUT = 1800
+TIMEOUT = 7200
```

All four full runs used:

```text
bench                    live_bench/coding
release                  2024-11-25
parallel requests        4
max tokens               32768
temperature              1.0
streaming                disabled
resume                   enabled
incremental grading      disabled
request timeout          7200 s
```

Exact shared command:

```bash
python run_livebench.py \
  --model MODEL_ID \
  --model-provider-override openai \
  --api-base http://192.168.8.210:3009/v1 \
  --api-key EMPTY \
  --bench-name live_bench/coding \
  --livebench-release-option 2024-11-25 \
  --parallel-requests 4 \
  --max-tokens 32768 \
  --force-temperature 1.0 \
  --no-incremental-grading \
  --resume
```

### Per-model request configuration

| Model | top_p | top_k | min_p | reasoning |
|---|---:|---:|---:|---|
| Qwen NVFP4 | 0.95 | 20 | not set | `reasoning_effort: xhigh` |
| Qwen GGUF | 0.95 | 20 | not set | `reasoning_effort: xhigh` |
| Laguna | 1.0 | 20 | 0.0 | no explicit reasoning field in YAML |
| Nemotron | 0.95 | not set | not set | `enable_thinking: true`, `force_nonempty_content: true` |

Exact historical YAML is reproduced under [configs/](configs/).

## Timing and token statistics

The same calculation was applied to all four models: concatenate the 78 generation and 50 completion records, compute wall span from saved timestamps, and aggregate `total_time_s` and token fields.

| Metric | Qwen NVFP4 | Qwen GGUF | Laguna | Nemotron |
|---|---:|---:|---:|---:|
| requests | 128 | 128 | 128 | 128 |
| wall span | 06:21:26.776 | 07:35:47.147 | 08:56:05.703 | 06:35:05.241 |
| sum request time (s) | 90,364.70 | 107,234.10 | 128,133.10 | 94,402.06 |
| average request (s) | 705.974 | 837.766 | 1,001.040 | 737.516 |
| p50 request (s) | 290.320 | 228.705 | 918.725 | 250.955 |
| p90 request (s) | 2,297.717 | 3,009.867 | 2,080.626 | 2,943.017 |
| p95 request (s) | 2,317.573 | 3,399.027 | 2,462.934 | 2,952.072 |
| input tokens | 79,172 | 77,879 | 91,396 | 86,183 |
| output tokens | 1,563,453 | 639,747 | 1,227,729 | 1,049,505 |

Token totals across vLLM and llama.cpp should not be treated as perfectly interchangeable because backend/chat-template reasoning accounting can differ.

## Throughput from retained logs

vLLM values are periodic scheduler-log statistics; llama.cpp values come from completed per-request timing records. They are useful, but they are not the same measurement method.

| Model | Prompt throughput | Generation throughput |
|---|---|---|
| Qwen NVFP4 | avg 4.057 tok/s; peak sample 295.4 | avg **55.842 tok/s**; peak 61.2 |
| Nemotron NVFP4 | avg 3.712 tok/s; peak sample 215.2 | avg **44.114 tok/s**; peak 46.0 |
| Qwen GGUF | per-request avg 405.471; token-weighted 393.333 | per-request avg **10.824 tok/s**; token-weighted 10.276 |
| Laguna GGUF | per-request avg 376.126; token-weighted 364.049 | per-request avg **9.656 tok/s**; token-weighted 9.602 |

## Retained host telemetry

Beszel retained two-hour aggregate records overlapping each benchmark window. These are host/system aggregates, not GPU telemetry.

| Model | RAM avg / peak GiB | Swap avg / peak GiB | ACPI temp avg / peak °C |
|---|---:|---:|---:|
| Qwen NVFP4 | 93.503 / 95.67 | 6.143 / 6.24 | 79.50 / 81.68 |
| Qwen GGUF | 113.965 / 121.17 | 12.108 / 15.42 | 79.13 / 80.93 |
| Laguna GGUF | 120.546 / 121.63 | 6.124 / 7.32 | 73.23 / 78.74 |
| Nemotron NVFP4 | 109.118 / 121.47 | 4.060 / 5.07 | 67.26 / 69.89 |

Benchmark-window GPU clocks, GPU temperature, power, and swap-in/swap-out were **not retained in the audited logs**. Earlier interactive point samples from the test session are therefore not used as reproducible benchmark telemetry here.

## Reproduction

1. Start exactly one inference server on the GB10 host and expose its OpenAI-compatible API on port 3009.
2. Verify it with:

```bash
curl -s http://localhost:3009/v1/models | jq .
```

3. On the N150, run the benchmark helper:

```bash
cd ~/livebench
./run-coding.sh all
```

4. Grade existing answers without rerunning inference:

```bash
./scripts/grade-existing.sh <benchmark-model-id>
```

5. Extract timing/token stats:

```bash
./scripts/collect-stats.sh <benchmark-model-id>
```

The repository's `scripts/run-coding.sh` is a cleaned reproduction helper. The exact historical runtime commands and configs are preserved in this README, under `configs/`, and in the full audit.

## Namespaced Nemotron model-ID issue

The API model ID was:

```text
nvidia/nemotron-3-super
```

LiveBench wrote this into nested paths such as:

```text
model_answer/nvidia/nemotron-3-super.jsonl
```

All 128 responses existed, but grading initially reported:

```text
models: []
No question-answer pairs found
```

The already-generated answer files were repaired for grading by copying them to a flat `nemotron-3-super.jsonl` path and changing only `model_id`. No inference had to be repeated. The helper `scripts/repair-namespaced-model.sh` documents the repair.

## Interpretation and limitations

The most useful result is the generation/completion split rather than a single overall number. Qwen is much stronger at code completion; Laguna and Nemotron score better on LCB generation. Repo-level agent benchmarks are still needed before extrapolating this to autonomous software-engineering performance.

Important limitations:

- one physical GB10 system;
- one full run per model, so no confidence intervals;
- different quantizations and inference backends;
- Qwen NVFP4 and Qwen GGUF had 15 and 14 API/error records respectively;
- some Qwen/Nemotron requests consumed the full 32,768-token budget;
- token accounting differs by backend/template;
- Beszel telemetry is two-hour aggregate host data, not fine-grained GPU telemetry.

## Repository contents

```text
.
├── README.md
├── assets/
│   ├── overall-score.svg
│   ├── task-breakdown.svg
│   └── wall-time.svg
├── configs/
│   ├── Qwen3.8-Flash-Next-NVFP4.yaml
│   ├── qwen3.8-flash-next-gguf.yaml
│   ├── laguna-s-2.1-gguf.yaml
│   └── nvidia_nemotron-3-super.yaml
├── docs/
│   └── gb10-livebench-audit.md
├── patches/
│   └── livebench-timeout-7200.patch
├── results/
│   ├── metadata.json
│   └── results.csv
├── scripts/
│   ├── run-coding.sh
│   ├── collect-stats.sh
│   ├── grade-existing.sh
│   ├── repair-namespaced-model.sh
│   └── reset-and-run-all.sh
└── posts/
    ├── linkedin.md
    ├── reddit.md
    └── nvidia-forums.md
```

## References

- NVIDIA DGX Spark: https://www.nvidia.com/en-us/products/workstations/dgx-spark/
- HP ZGX Nano G1n: https://www.hp.com/us-en/shop/pdp/hp-zgx-nano-g1n-ai-station-p-cz2v8ut-aba-1
- LiveBench: https://github.com/LiveBench/LiveBench
- Qwen NVFP4 artifact: https://huggingface.co/MagneticLab/Qwen3.8-Flash-Next-NVFP4
- Qwen GGUF artifact: https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF
- Laguna GGUF artifact: https://huggingface.co/unsloth/Laguna-S-2.1-GGUF
- NVIDIA Nemotron 3 Super NVFP4: https://huggingface.co/nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4
