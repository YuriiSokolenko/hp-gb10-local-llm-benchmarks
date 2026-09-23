# GB10 / HP ZGX Nano G1n LiveBench Coding audit

Audit date: 2026-09-23 (Europe/Tirane). Hosts inspected read-only over SSH: `nano` (`192.168.8.210`) and `n150` (`192.168.8.184`, SSH alias `beelink`). No model was started, stopped, or restarted; no inference was launched; no existing script, configuration, result, container, image, cache, or model file was changed. The only created file is this report.

Unless explicitly labelled otherwise, byte counts are decimal bytes and GiB means bytes / 2^30. A value is `not found` where the surviving files or logs did not establish it.

## 1. System / GB10 (`nano`)

### Operating system and CPU

```text
uname -a
Linux nano 6.17.0-1018-nvidia #18-Ubuntu SMP PREEMPT_DYNAMIC Tue May  5 21:28:33 UTC 2026 aarch64 aarch64 aarch64 GNU/Linux
```

`/etc/os-release` identifies Ubuntu 24.04.5 LTS (Noble Numbat). Kernel: `6.17.0-1018-nvidia`; `/proc/version` reports GCC 13.3.

CPU architecture is `aarch64`, one socket, 20 cores, one thread/core, CPUs 0-19 online. The heterogeneous topology reported by sysfs/`lscpu` is 10 × Arm Cortex-X925 (maximum 3,900 MHz) plus 10 × Arm Cortex-A725 (maximum 2,808 MHz). Caches: L1d 1.3 MiB (20 instances), L1i 1.3 MiB (20), L2 25 MiB (20), L3 24 MiB (2). One NUMA node.

### Memory and storage

Audit point sample:

| Metric | Exact bytes | GiB |
|---|---:|---:|
| RAM total | 130,596,184,064 | 121.63 |
| RAM available | 126,640,553,984 | 117.94 |
| Swap total | 17,179,865,088 | 16.00 |
| Swap free | 17,179,865,088 | 16.00 |

Primary SSD: `/dev/nvme0n1`, model `ESL04TBTLCZ-27J4-TYN`, serial `0125502000262`, NVMe/non-rotating, 4,000,787,030,016 bytes. Root partition `/dev/nvme0n1p2` is ext4 and 4,000,247,185,408 bytes.

### NVIDIA, CUDA, Docker, and container runtime

| Item | Verified value |
|---|---|
| Accelerator | NVIDIA GB10 |
| NVIDIA driver | `580.159.03` |
| Kernel module | NVIDIA open kernel module `580.159.03` |
| `nvidia-smi` CUDA compatibility level | `13.0` |
| Installed CUDA SDK | `13.0.3` (`/usr/local/cuda/version.json`) |
| CUDA compiler component | `13.0.88` |
| CUDA runtime component | `13.0.96` |
| Docker client/server | `29.2.1`, API `1.53`, client git `a5c7197`, server git `6bc6209` |
| containerd | `2.2.1`, commit `dea7...` |
| runc | `1.3.4` |
| Docker architecture | `linux/arm64` |
| NVIDIA Container Toolkit CLI | `1.20.0`, commit `5505e2f94d9aaa08561490db974ba3cd676af209` |
| NVIDIA container packages | `libnvidia-container1`, `libnvidia-container-tools`, `nvidia-container-toolkit`, and `nvidia-container-toolkit-base`, all `1.20.0-1` |

Docker reports the `runc` and `io.containerd.runc.v2` runtimes; no separately named `nvidia` runtime is configured and `/etc/docker/daemon.json` was not found. NVIDIA access is exposed through CDI directories `/etc/cdi` and `/var/run/cdi`; discovered CDI devices included `nvidia.com/gpu=0`, the GPU UUID, and `nvidia.com/gpu=all`.

The audit-time idle point sample was 39 °C, 5.59 W, and 208 MHz graphics clock, with no GPU process reported. GB10 unified-memory usage is not reported by `nvidia-smi`; these are not benchmark telemetry.

## 2. Model provenance

### Summary

| Benchmark model | Local model path on `nano` | Hugging Face repository | Exact revision | Weight bytes | GiB |
|---|---|---|---|---:|---:|
| Qwen3.8-Flash-Next NVFP4 | `/opt/models/Qwen3.8-Flash-Next-NVFP4` | `MagneticLab/Qwen3.8-Flash-Next-NVFP4` | `e30ead75503c0b734af6ec0614ef22089eee6bf3` | 115,995,354,872 | 108.029092543 |
| Qwen3.8-Flash-Next GGUF UD-Q4_K_XL | `/home/yurasik/models/Qwen3.8-Flash-Next-GGUF/UD-Q4_K_XL` | `unsloth/Qwen3.8-Flash-Next-GGUF` | `38bb39ee97821de2c9009abb7e93950eec396e66` | 111,334,654,784 | 103.688477337 |
| Laguna S 2.1 GGUF UD-Q6_K_XL | `/home/yurasik/models/Laguna-S-2.1-GGUF/UD-Q6_K_XL` | `unsloth/Laguna-S-2.1-GGUF` | `750f92f90cf54159c4d7a610cb7b3e74498e75c6` | 107,079,627,552 | 99.725674421 |
| NVIDIA Nemotron 3 Super 120B-A12B NVFP4 | `/home/yurasik/models/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4` | `nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4` | `ff433f5493e25d631c9f12b5d55c674229923d02` | 80,317,948,856 | 74.801918916 |

The two Unsloth repository/revision pairs were independently accepted by the Hugging Face model API. Qwen NVFP4 and Nemotron provenance is retained in their download scripts and Hugging Face cache metadata.

### Qwen3.8-Flash-Next NVFP4 manifest

The served ModelOpt weight directory is `/opt/models/Qwen3.8-Flash-Next-NVFP4/qwen-nvfp4-modelopt`; PLE sidecars are `/opt/models/Qwen3.8-Flash-Next-NVFP4/ple-sidecar/ples_nvfp4`. The download script deliberately retained model shards 1-5 and 37-131 (100 files), not nominal shards 6-36. The active index refers to the retained set. Model shards total 87,195,184,376 bytes (81.206843607 GiB); 128 PLE sidecars total 28,800,170,496 bytes (26.822248936 GiB). Total directory size, including configuration/cache metadata, was 116,081,788,611 bytes (108.109590235 GiB).

Every retained model filename and byte size follows. Files on one line have the same size.

```text
511012384: model-00059-of-00131.safetensors
511014224: model-00039,00055,00074,00080,00084,00092,00110-of-00131.safetensors
511014600: model-00100-of-00131.safetensors
511034808: model-00118-of-00131.safetensors
511096280: model-00047-of-00131.safetensors
513635776: model-00066-of-00131.safetensors
524119568: model-00124-of-00131.safetensors
626931608: model-00003,00122,00128-of-00131.safetensors
626931624: model-00104-of-00131.safetensors
626933680: model-00045,00051,00062,00064,00096,00098,00116-of-00131.safetensors
626938904: model-00114-of-00131.safetensors
626938920: model-00070-of-00131.safetensors
627015736: model-00078-of-00131.safetensors
630210608: model-00090-of-00131.safetensors
633487408: model-00043-of-00131.safetensors
633487416: model-00088-of-00131.safetensors
633487424: model-00053-of-00131.safetensors
633487528: model-00072-of-00131.safetensors
658391072: model-00106-of-00131.safetensors
695091456: model-00108-of-00131.safetensors
729825856: model-00126-of-00131.safetensors
729827936: model-00068-of-00131.safetensors
729828312: model-00094-of-00131.safetensors
729828544: model-00102-of-00131.safetensors
729828560: model-00112-of-00131.safetensors
729846472: model-00082-of-00131.safetensors
729848536: model-00049-of-00131.safetensors
733104864: model-00076-of-00131.safetensors
736381664: model-00057-of-00131.safetensors
736381672: model-00041-of-00131.safetensors
736381680: model-00086-of-00131.safetensors
742935224: model-00120-of-00131.safetensors
944264696: model-00002,00004,00058,00081,00103,00121,00123,00125,00127,00129-of-00131.safetensors
944268792: model-00038,00040,00042,00044,00046,00048,00050,00052,00054,00056,00061,00063,00065,00067,00069,00071,00073,00075,00077,00079,00083,00085,00087,00089,00091,00093,00095,00097,00099,00101,00105,00107,00109,00111,00113,00115,00117,00119-of-00131.safetensors
1040155912: model-00001-of-00131.safetensors
1271398496: model-00131-of-00131.safetensors
1742347128: model-00037-of-00131.safetensors
1769203624: model-00130-of-00131.safetensors
2150303960: model-00005-of-00131.safetensors
5149083216: model-00060-of-00131.safetensors
```

PLE files are exactly `shard_0.safetensors` through `shard_127.safetensors`; every one is 225,001,332 bytes.

SHA-256 was practical without rereading the 116 GB payload because every Hugging Face LFS object has its SHA-256 in local `.metadata`. A canonical sorted manifest of `relative-path|size|sha256` for all 228 active files has SHA-256 `6cff26d715b02bfc03db1d8698a472acdbbccfbc6bdbf2c7bd08f00e0263167c`. The exact per-file values can be reproduced without touching model contents with:

```bash
root=/opt/models/Qwen3.8-Flash-Next-NVFP4
for sub in qwen-nvfp4-modelopt ple-sidecar/ples_nvfp4; do
  find "$root/$sub" -maxdepth 1 -type f -name '*.safetensors' -print0
done | sort -z | while IFS= read -r -d '' f; do
  rel=${f#"$root/"}
  printf '%s|%s|%s\n' "$rel" "$(stat -c %s "$f")" \
    "$(sed -n '2p' "$root/.cache/huggingface/download/$rel.metadata")"
done
```

### GGUF manifests

All hashes below were computed over the existing files.

```text
Qwen3.8-Flash-Next-UD-Q4_K_XL-00001-of-00004.gguf | 10946624    | 4448186216b3af4cc558bbce2c3213f01608f8f8b2e5267a9767971dd3ec8082
Qwen3.8-Flash-Next-UD-Q4_K_XL-00002-of-00004.gguf | 49859583136 | 3f342f1c1580473f1ee94ddd5b28206e8c07a70fa1a366f59d1d6c922919a6c9
Qwen3.8-Flash-Next-UD-Q4_K_XL-00003-of-00004.gguf | 49376141504 | 56758f40269cad5cd9b0d3d6fbae0f40f6d5be6de49e4ab392dbe83157d9cbd3
Qwen3.8-Flash-Next-UD-Q4_K_XL-00004-of-00004.gguf | 12087983520 | 753bda48b98ba4f1636134a90a967de1b2d3908a236c026e464777342e53510a

Laguna-S-2.1-UD-Q6_K_XL-00001-of-00004.gguf | 3683648     | e7fe690509db46d9303c2e27ad251c7439376d34d22241dbc085b2f5c96965c6
Laguna-S-2.1-UD-Q6_K_XL-00002-of-00004.gguf | 49714573632 | a6c8bf20cde41c8b6d43418f8b1326afaf3aac3184fb5056c9da61dbcf6aacc7
Laguna-S-2.1-UD-Q6_K_XL-00003-of-00004.gguf | 49535976704 | eb92c5ac517257413418c9a064ca1ec0b83a7c9454352693cd4bedf16fa95fcb
Laguna-S-2.1-UD-Q6_K_XL-00004-of-00004.gguf | 7825393568  | faa6e791d9a5067f7ad1ff5fd4f45e8db58ee29bcc8ad95e6eaadaa924b28ce1
```

### Nemotron safetensors manifest

All hashes below were computed over the existing files. Non-weight payload size from the completed download report was 80,365,684,262 bytes total including configs/tokenizer (74.846375978 GiB).

```text
model-00001-of-00017.safetensors | 5000122600 | 3d31c241fb777f44342ac3c298147bb82ddcaa64214c555494d8fab397218d0e
model-00002-of-00017.safetensors | 4977660672 | 78d4a5ad26841e04ea92ae3d6b6b29ab9069b4ea27155b93213a5bfbeef85081
model-00003-of-00017.safetensors | 5001219144 | ecb72debb5d274b4beb74fb993a44e4f8ac27d640ecadaf656ed7de178942429
model-00004-of-00017.safetensors | 5000841128 | a7d1c68e827296ee4bfc0ca4fe2c6a545c48b7a7f5148d9ebf4872c6fb123106
model-00005-of-00017.safetensors | 5000389560 | 1d432c9c783453c6efa69d01228023b407be77e7bfea2909b2023c03df07df6a
model-00006-of-00017.safetensors | 4995800552 | 037ea60b87cb2b8ce12beb7164c5382f4d97723c24cdbacc9fc188ae5a28f47b
model-00007-of-00017.safetensors | 5000688960 | 3c0527dac96fd91874427f04e92c1df43585503608a487a4c8ffcf9d5f925bd4
model-00008-of-00017.safetensors | 5000478392 | ef6e73f64c3d7242a50230a288811eaa56aa2d9c6da9040b90361e6b9245bc26
model-00009-of-00017.safetensors | 5000199288 | b4f598068350b93d42c486e537239dabc4661545ea2d39c8f0bb7ca23223c4f5
model-00010-of-00017.safetensors | 4997005048 | bf8bf1f4e2e01591c3d91f4b51f4f00252e14715132278177cab6ecc76511884
model-00011-of-00017.safetensors | 5000780360 | ac436f2e1af8185dc3b093e1527f3297b93fd639ab84ad208376bd82d5e94e94
model-00012-of-00017.safetensors | 5000527232 | 7814c9ae0dc394beb4709ebf0c7e976214e2770b322fa2422bc467446dd97023
model-00013-of-00017.safetensors | 5001126000 | b13aa79c0879539c4a514489497bccd21e23ec597d8112ba91808767fcbd4d92
model-00014-of-00017.safetensors | 5000330504 | 1d8781b2643ca6566e7bdae77c275b62785de3502c5337b8cb53558df2477eed
model-00015-of-00017.safetensors | 4996320352 | 5f6c3c0f842055418b0420dbeeba6b737d892d9d849725d956603a714f44745e
model-00016-of-00017.safetensors | 4998674800 | a5f795056a1ac69546ce8f5bccdcab3b6cb7142426024a81f23c15d3d45aa51e
model-00017-of-00017.safetensors | 345784264  | 218355cf69f1f9d3efa1b5c8b5f531e28e1aa50a3d869ee768ba9835d936e182
```

## 3. Inference server configuration

### Qwen NVFP4 / vLLM

Launcher: `/home/yurasik/infra/qwen38-flash-next/start-qwen38-flash-next.sh`; Compose file: `/home/yurasik/infra/qwen38-flash-next/docker-compose.yml`.

Image tag `vllm/vllm-openai:qwen38-flash-next`; local image ID `sha256:d464f3b466fa9c45ddbff8a812e80564503b6879a9fd95c1a47514f3f0df5a4a`; repository digest `sha256:fc120ece0a388cc0aa1caad4a9f1cd92113484ab7ec2fd0efadd62585be05bf8`; vLLM `0.1.dev20073+g8e685d198`.

Exact effective command recovered from the stopped benchmark container:

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

Effective dtype was `bfloat16`; tensor/pipeline/data parallel were 1/1/1; KV cache dtype was `auto`; prefix caching and chunked prefill were enabled. `gpu_memory_utilization` was not passed (default 0.9), but the log explicitly says it was ignored because `--kv-cache-memory-bytes 10737418240` fixed the KV allocation. Other relevant environment included 1 GiB CPU offload and the PLE quantization directory. The engine reported maximum 1.57× concurrency at 262,144 tokens.

### Nemotron / vLLM

Launcher: `/home/yurasik/infra/nemotron3-super/start-nemotron3-super.sh`; Compose file: `/home/yurasik/infra/nemotron3-super/docker-compose.yml`.

Image tag `vllm/vllm-openai:v0.27.1`; local image ID `sha256:2c211a1273b48e8929f893b267aeb1509e6b84654cdbde1bad56d79e3964224d`; repository digest `sha256:0a51ea5b4ae2dc5d81890e5173f54203d2a3ae0cfffe51b8fd2afd4391bfd967`; vLLM `0.27.1`.

Exact effective command from the actual stopped benchmark container:

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

This proves that the benchmark context was **exactly 204,800**, not 200,000. The checked-in Compose default currently says 262,144, but the actual container command overrides it to 204,800. Effective dtype was BF16, quantization resolved to `modelopt_mixed`, KV cache to `fp8_e4m3`, prefix caching was false, and TP/PP/DP were 1/1/1. `max_num_batched_tokens` was not passed and an exact effective value was not found in the surviving log. Relevant environment: `VLLM_NVFP4_GEMM_BACKEND=marlin`, `VLLM_USE_FLASHINFER_MOE_FP4=0`, and `VLLM_FLASHINFER_ALLREDUCE_BACKEND=trtllm`.

### Qwen GGUF and Laguna / llama.cpp

Launchers:

- Qwen wrapper: `/home/yurasik/infra/llama-gguf-experimental/start_qwen38_flash_next_ud_q4_k_xl.sh`; model definition: `lib/qwen.sh`.
- Laguna wrapper: `/home/yurasik/infra/llama-gguf-experimental/start_laguna_s_2_1_ud_q6_k_xl.sh`; model definition: `lib/laguna.sh`.
- Shared launcher: `/home/yurasik/infra/llama-gguf-experimental/lib/common.sh`.

Binary: `/home/yurasik/infra/llama-gguf-experimental/runtime/llama.cpp/build-gb10/bin/llama-server`. Git commit `18a04f09c24616898792bcfaa17f3550bdc78912` (detached HEAD), origin `https://github.com/ggml-org/llama.cpp`; reported version `0.4.1-dev`, build 11043. CMake cache: `Release`, `/usr/local/cuda/bin/nvcc`, CUDA architecture 121, `GGML_CUDA=ON`, `GGML_CUDA_FA=ON`, `GGML_CUDA_GRAPHS=ON`, and `GGML_NATIVE=ON`; the build notes resolve this to `sm_121a` on CUDA 13.

Exact command template, with model-specific values substituted by the launchers:

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

| Setting | Qwen GGUF | Laguna GGUF |
|---|---|---|
| `FIRST_SHARD` | `.../Qwen3.8-Flash-Next-UD-Q4_K_XL-00001-of-00004.gguf` | `.../Laguna-S-2.1-UD-Q6_K_XL-00001-of-00004.gguf` |
| Alias | `qwen3.8-flash-next-gguf` | `laguna-s-2.1-gguf` |
| Per-slot context | 262,144 | **204,800** |
| Total KV pool (4 slots) | 1,048,576 | 819,200 |
| Parallel slots | 4 | 4 |
| Batch / ubatch | 2,048 / 512 (effective defaults) | 2,048 / 512 (effective defaults) |
| Threads / batch threads | 20 / 20 from log | 20 / 20 from log |
| K/V cache | q4_0 / q4_0 | q4_0 / q4_0 |

Neither command passed `--mmap`, `--no-mmap`, or `--mlock`; load mode was `auto` and mlock remained off by default. An explicit effective mmap boolean was not found in the benchmark log. Both used 999 GPU layers, flash attention on, continuous batching, unified per-slot KV, and Jinja templates.

Laguna evidence is unambiguous: the earlier `laguna-s-2.1-gguf-20260922T034954Z.log` attempted 262,144 but stopped during loading and never listened. The successful benchmark log `/home/yurasik/infra/llama-gguf-experimental/logs/laguna-s-2.1-gguf-20260922T040508Z.log` loaded, listened, served all requests, and reports 204,800 per slot. Therefore the actual Laguna benchmark context was **204,800**.

## 4. LiveBench provenance (`n150`)

The host directory `/home/yurasik/livebench` is an experiment/data directory, not a Git worktree. The source worktree is embedded in the image at `/opt/LiveBench`:

| Item | Value |
|---|---|
| Repository | `https://github.com/LiveBench/LiveBench.git` |
| Path in image | `/opt/LiveBench` |
| Commit | `1263ee472f4b9ac3833c0d2f6ad50dd3747fd1df` |
| Branch | `main` |
| Commit date/message | `2026-09-19T01:20:32+01:00`, merge PR 543 (`fix/litellm-429-backoff`) |
| Image tag | `n150/livebench:latest` |
| Local image ID/content digest | `sha256:0fc3818ba0ed91a5753f3f87a5c2ec7601031580c4659482f1ea95588aee8934` |
| Repository digest | not found (locally built image) |
| Compressed/content size from inspect | 2,671,446,104 bytes |
| Docker virtual/unpacked display size | 8.74 GB |
| Image creation time | `2026-09-21T05:59:12Z` |
| Python / pip | Python `3.10.21`; pip `26.2.1` |

Build recipe: `/home/yurasik/livebench/Dockerfile`. It starts from `python:3.10-slim`, installs Git/curl/CA certificates/build-essential, shallow-clones LiveBench, installs it editable plus requirements, changes the timeout, and writes `LIVEBENCH_COMMIT`.

Relevant installed packages: editable LiveBench at commit `1263ee...`, `openai 2.54.0`, `litellm 1.102.0`, `httpx 0.28.1`, `datasets 5.0.1`, `huggingface_hub 1.32.0`, `pandas 2.2.3`, `numpy 2.2.6`, `pyarrow 25.0.1`, `requests 2.34.2`, and `PyYAML 6.0.3`.

The exact local image modification that extends request timeout is:

```diff
diff --git a/livebench/model/completions.py b/livebench/model/completions.py
@@ -23,7 +23,7 @@
-TIMEOUT = 1800
+TIMEOUT = 7200
```

`git status` inside the image showed only that tracked modification plus untracked `LIVEBENCH_COMMIT`. The constant is passed to the OpenAI/httpx client timeout.

## 5. Exact benchmark configurations

All four full runs used temperature 1.0, 4 parallel requests, maximum 32,768 tokens, streaming disabled, resume enabled, incremental grading disabled, release `2024-11-25`, and bench `live_bench/coding`.

### Exact model YAML

`/home/yurasik/livebench/config/Qwen3.8-Flash-Next-NVFP4.yaml`:

```yaml
display_name: "qwen3.8-flash-next-nvfp4"
api_name:
  openai: "Qwen3.8-Flash-Next-NVFP4"
default_provider: openai
api_kwargs:
  openai:
    top_p: 0.95
    extra_body:
      top_k: 20
      chat_template_kwargs:
        reasoning_effort: xhigh
```

`/home/yurasik/livebench/config/qwen3.8-flash-next-gguf.yaml` is identical except both names are `qwen3.8-flash-next-gguf`. In both Qwen configs, `min_p` and `enable_thinking` are not set.

`/home/yurasik/livebench/config/laguna-s-2.1-gguf.yaml`:

```yaml
display_name: "laguna-s-2.1-gguf"
api_name:
  openai: "laguna-s-2.1-gguf"
default_provider: openai
api_kwargs:
  openai:
    top_p: 1.0
    extra_body:
      top_k: 20
      min_p: 0.0
```

Laguna's script labels reasoning as `thinking`, but neither `reasoning_effort` nor `enable_thinking` appears in the YAML; an exact explicit value is therefore not found. `force_nonempty_content` is not set.

`/home/yurasik/livebench/config/nvidia_nemotron-3-super.yaml`:

```yaml
display_name: "nvidia/nemotron-3-super"
api_name:
  openai: "nvidia/nemotron-3-super"
default_provider: openai
api_kwargs:
  openai:
    top_p: 0.95
    extra_body:
      chat_template_kwargs:
        enable_thinking: true
        force_nonempty_content: true
```

Nemotron `top_k`, `min_p`, and `reasoning_effort` are not set.

### Actual command

For each model, `run-coding.sh all` supplied no question range and expanded to:

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

`MODEL_ID` was respectively `Qwen3.8-Flash-Next-NVFP4`, `qwen3.8-flash-next-gguf`, `laguna-s-2.1-gguf`, and `nvidia/nemotron-3-super`. Nemotron first had a two-question test (`./run-coding.sh 2`) and then the full resumed run (`./run-coding.sh all`); the final files below contain the full 78 + 50 scored requests. Shell history directly retains `./run-coding.sh all` for Qwen GGUF, Laguna, and Nemotron. For Qwen NVFP4, the exact internal command/config is evidenced by the script, mounted YAML, and result `api_info`; the outer shell invocation is not uniquely recoverable beyond the retained `reset-and-run-all.sh` / `run-coding.sh all` entries.

## 6. Result files

No result file was altered. Line counts:

```text
/home/yurasik/livebench/state/live_bench/coding/LCB_generation/model_answer/laguna-s-2.1-gguf.jsonl                         78
/home/yurasik/livebench/state/live_bench/coding/LCB_generation/model_answer/qwen3.8-flash-next-gguf.jsonl                78
/home/yurasik/livebench/state/live_bench/coding/LCB_generation/model_answer/qwen3.8-flash-next-nvfp4.jsonl               78
/home/yurasik/livebench/state/live_bench/coding/LCB_generation/model_answer/nvidia/nemotron-3-super.jsonl                78
/home/yurasik/livebench/state/live_bench/coding/LCB_generation/model_answer/nemotron-3-super.jsonl                       78
/home/yurasik/livebench/state/live_bench/coding/coding_completion/model_answer/laguna-s-2.1-gguf.jsonl                    50
/home/yurasik/livebench/state/live_bench/coding/coding_completion/model_answer/qwen3.8-flash-next-gguf.jsonl              50
/home/yurasik/livebench/state/live_bench/coding/coding_completion/model_answer/qwen3.8-flash-next-nvfp4.jsonl             50
/home/yurasik/livebench/state/live_bench/coding/coding_completion/model_answer/nvidia/nemotron-3-super.jsonl              50
/home/yurasik/livebench/state/live_bench/coding/coding_completion/model_answer/nemotron-3-super.jsonl                     50
/home/yurasik/livebench/state/live_bench/coding/LCB_generation/model_judgment/ground_truth_judgment.jsonl                312
/home/yurasik/livebench/state/live_bench/coding/coding_completion/model_judgment/ground_truth_judgment.jsonl             200
/home/yurasik/livebench/results/all_groups.csv                                                                             5
/home/yurasik/livebench/results/all_tasks.csv                                                                              5
```

The nested Nemotron answer files retain the API model ID. The flat `nemotron-3-super.jsonl` copies were produced for grading by changing only `model_id` to `nemotron-3-super`; they otherwise duplicate the 78 and 50 source records. Statistics below count the flat scored pair once, not both copies.

Scores:

| Model | Overall coding | LCB_generation | coding_completion |
|---|---:|---:|---:|
| qwen3.8-flash-next-gguf | 80.6 | 69.231 | 92.0 |
| qwen3.8-flash-next-nvfp4 | 77.6 | 69.231 | 86.0 |
| laguna-s-2.1-gguf | 67.0 | 82.051 | 52.0 |
| nemotron-3-super | 65.8 | 75.641 | 56.0 |

## 7. Timing and token statistics

Method used identically for all models: concatenate the 78 LCB-generation and 50 coding-completion answer records; use the record `tstamp` for first/last and `max(tstamp)-min(tstamp)` for wall span; use `total_time_s` for request time; sum the recorded input/output token fields. Percentiles are linear Type-7 quantiles (`h=(n-1)p`). They are descriptive of the 128 recorded requests, including error records.

| Metric | Qwen NVFP4 | Qwen GGUF | Laguna GGUF | Nemotron NVFP4 |
|---|---:|---:|---:|---:|
| requests | 128 | 128 | 128 | 128 |
| first_tstamp (Unix) | 1789975437.701519 | 1790000119.824599 | 1790050440.118355 | 1790087237.223732 |
| first_tstamp (UTC) | 2026-09-21 07:23:57.701519 | 2026-09-21 14:15:19.824599 | 2026-09-22 04:14:00.118355 | 2026-09-22 14:27:17.223732 |
| last_tstamp (Unix) | 1789998324.477507 | 1790027466.972028 | 1790082605.820932 | 1790110942.464453 |
| last_tstamp (UTC) | 2026-09-21 13:45:24.477507 | 2026-09-21 21:51:06.972028 | 2026-09-22 13:10:05.820932 | 2026-09-22 21:02:22.464453 |
| wall_span_seconds | 22,886.775988 | 27,347.147429 | 32,165.702577 | 23,705.240721 |
| wall_span_hh:mm:ss | 06:21:26.776 | 07:35:47.147 | 08:56:05.703 | 06:35:05.241 |
| sum_request_seconds | 90,364.70 | 107,234.10 | 128,133.10 | 94,402.06 |
| avg_request_seconds | 705.974 | 837.766 | 1,001.040 | 737.516 |
| min_request_seconds | 6.60 | 7.17 | 48.53 | 15.56 |
| max_request_seconds | 2,335.88 | 3,544.71 | 3,409.47 | 2,964.22 |
| p50_request_seconds | 290.320 | 228.705 | 918.725 | 250.955 |
| p90_request_seconds | 2,297.717 | 3,009.867 | 2,080.626 | 2,943.017 |
| p95_request_seconds | 2,317.573 | 3,399.027 | 2,462.934 | 2,952.072 |
| total_input_tokens | 79,172 | 77,879 | 91,396 | 86,183 |
| total_output_tokens | 1,563,453 | 639,747 | 1,227,729 | 1,049,505 |

## 8. Failure and truncation analysis

Definitions: “empty” means the concatenated assistant turn content is blank; “API error” means the stored answer is the LiveBench `$ERROR$` failure sentinel/error form; “lacking normal content” means no non-error assistant message/content; “obviously failed” is the union of those clear failures. Timeout/error records were searched for timeout/error indicators separately. The `>=32768` JSON column uses the answer JSONL token accounting only.

| Model | Total answers | Empty | API errors | Timeout/error records | JSON output tokens >=32768 | Lacking normal assistant content | Obviously failed |
|---|---:|---:|---:|---:|---:|---:|---:|
| Qwen NVFP4 | 128 | 0 | 15 | 0 | 20 | 15 | 15 |
| Qwen GGUF | 128 | 0 | 14 | 0 | 0 | 14 | 14 |
| Laguna GGUF | 128 | 0 | 0 | 0 | 0 | 0 | 0 |
| Nemotron NVFP4 | 128 | 0 | 0 | 0 | 15 | 0 | 0 |

Important Qwen GGUF qualification: the answer JSONLs store zero usage tokens for its 14 `$ERROR$` records, so the JSON-only `>=32768` count is zero. The llama.cpp benchmark server log independently contains **14 completed generations at exactly 32,768 generated tokens**; these match the count of the 14 LiveBench API-error/no-normal-message records. The known long response is therefore not isolated: the server log shows 14 max-token completions, with one inspected example recording 32,768 generated tokens and about 2,900 seconds total. This is the max-token truncation count used in the final table.

For Qwen NVFP4, 20 JSON records account for at least 32,768 output tokens, sometimes more because reasoning/content accounting is combined; an exact finish-reason truncation flag was not found. Nemotron has 15 records exactly at 32,768. Laguna has none.

## 9. Performance and telemetry

### Throughput from existing inference logs

vLLM values are arithmetic statistics over the periodic throughput log samples (including zero-idle samples for the average). llama.cpp values are over its 128 completed per-request timing records; the token-weighted rate is total tokens divided by total phase time. These two logging methods are not directly equivalent.

| Model | Prompt throughput | Generation throughput | Source/type |
|---|---|---|---|
| Qwen NVFP4 | average 4.057 tok/s; peak sample 295.4 tok/s | average 55.842 tok/s; peak sample 61.2 tok/s; nonzero-sample average 55.867 | 2,293 vLLM periodic log samples |
| Nemotron NVFP4 | average 3.712 tok/s; peak sample 215.2 tok/s | average 44.114 tok/s; peak sample 46.0 tok/s; nonzero-sample average 44.151 | 2,380 vLLM periodic log samples |
| Qwen GGUF | per-request average 405.471 tok/s; token-weighted 393.333; peak request 583.73 | per-request average 10.824 tok/s; token-weighted 10.276; peak request 14.48 | 128 llama.cpp completion timings |
| Laguna GGUF | per-request average 376.126 tok/s; token-weighted 364.049; peak request 522.22 | per-request average 9.656 tok/s; token-weighted 9.602; peak request 12.03 | 128 llama.cpp completion timings |

### Host telemetry retained by Beszel

The retained history is in two-hour aggregate records overlapping each benchmark window. “RAM average” below is the arithmetic mean of recorded `mu` aggregate fields; peak is the maximum recorded `mm`. Swap is treated the same. Temperature is ACPI/system temperature, not GPU temperature.

| Model | Aggregate records | RAM avg / peak GiB | Swap avg / peak GiB | ACPI temperature avg / peak °C |
|---|---:|---:|---:|---:|
| Qwen NVFP4 | 3 | 93.503 / 95.67 | 6.143 / 6.24 | 79.50 / 81.68 |
| Qwen GGUF | 4 | 113.965 / 121.17 | 12.108 / 15.42 | 79.13 / 80.93 |
| Laguna GGUF | 5 | 120.546 / 121.63 | 6.124 / 7.32 | 73.23 / 78.74 |
| Nemotron NVFP4 | 4 | 109.118 / 121.47 | 4.060 / 5.07 | 67.26 / 69.89 |

Benchmark-window GPU/accelerator clocks, GPU temperature, power, and swap-in/swap-out were **not recorded** in the available logs. The idle audit point in section 1 is not substituted for benchmark telemetry. The RAM/swap/ACPI values above are measured aggregate log fields, not inferred from model size.

## 10. N150 LiveBench client

```text
uname -a
Linux n150 7.0.0-31-generic #31-Ubuntu SMP PREEMPT_DYNAMIC Sat Aug  1 04:26:38 UTC 2026 x86_64 GNU/Linux
```

Ubuntu 26.04 LTS (Resolute Raccoon); Intel N150, x86_64, 4 cores/4 threads, one socket, maximum 3,600 MHz and minimum 700 MHz. Caches: L1d 128 KiB, L1i 256 KiB, L2 2 MiB, L3 6 MiB.

Audit point memory: 15,985,524,736 bytes total (14.89 GiB), 11,941,183,488 bytes available; swap 4,294,963,200 bytes total and free.

Docker client/server `29.5.3`, API `1.54`, client git `d1c06ef`, server git `285b471`; containerd `2.2.4` (`193637...`); runc `1.3.5`.

The route to `nano` is via Wi-Fi interface `wlo1`, source address `192.168.8.184`; link was up. `iw` and `nmcli` are absent and `ethtool` could report only “Link detected: yes,” so negotiated link speed is **not found**. Ethernet interfaces `enp1s0` and `enp2s0` had no carrier.

## 11. Experiment file inventory

Sizes and mtimes are from `stat`; timestamps are UTC. Model weights are inventoried in section 2 and are not repeated here.

### `nano:/home/yurasik/infra`

| Path | Purpose | Bytes | mtime UTC |
|---|---|---:|---|
| `/home/yurasik/infra/qwen38-flash-next/start-qwen38-flash-next.sh` | Qwen NVFP4 launcher | 1,837 | 2026-09-18 03:54:41.347008820 |
| `/home/yurasik/infra/qwen38-flash-next/docker-compose.yml` | Qwen vLLM container definition | 1,735 | 2026-09-18 09:30:02.264231542 |
| `/home/yurasik/infra/qwen38-flash-next/download-qwen38-flash-next.sh` | Pinned Qwen model downloader | 3,154 | 2026-09-18 03:54:41.263008630 |
| `/home/yurasik/infra/nemotron3-super/start-nemotron3-super.sh` | Nemotron launcher | 2,295 | 2026-09-22 06:49:09.142707220 |
| `/home/yurasik/infra/nemotron3-super/docker-compose.yml` | Nemotron vLLM container definition | 1,739 | 2026-09-22 06:49:09.040704699 |
| `/home/yurasik/infra/nemotron3-super/status-nemotron3-super.sh` | Server status helper | 723 | 2026-09-22 06:49:09.280710631 |
| `/home/yurasik/infra/nemotron-3-super-120b-a12b-nvfp4-download/download.sh` | Pinned Nemotron downloader | 3,621 | 2026-09-21 15:39:17.467790356 |
| `/home/yurasik/infra/nemotron-3-super-120b-a12b-nvfp4-download/download.log` | Model download log | 3,391 | 2026-09-21 18:32:21.297330877 |
| `/home/yurasik/infra/llama-gguf-experimental/README.md` | GB10 llama.cpp setup/build notes | 5,734 | 2026-09-18 20:49:53.692982184 |
| `/home/yurasik/infra/llama-gguf-experimental/lib/common.sh` | Shared llama-server launcher | 7,579 | 2026-09-18 20:49:54.465982422 |
| `/home/yurasik/infra/llama-gguf-experimental/lib/qwen.sh` | Qwen GGUF model parameters | 587 | 2026-09-18 20:49:54.515982437 |
| `/home/yurasik/infra/llama-gguf-experimental/lib/laguna.sh` | Laguna GGUF model parameters | 635 | 2026-09-18 20:49:54.656982481 |
| `/home/yurasik/infra/llama-gguf-experimental/start_qwen38_flash_next_ud_q4_k_xl.sh` | Qwen wrapper | 170 | 2026-09-18 20:44:00.946687148 |
| `/home/yurasik/infra/llama-gguf-experimental/start_laguna_s_2_1_ud_q6_k_xl.sh` | Laguna wrapper | 172 | 2026-09-18 20:44:00.893687408 |
| `/home/yurasik/infra/llama-gguf-experimental/logs/qwen3.8-flash-next-gguf-20260921T141048Z.log` | Successful Qwen benchmark server log | 3,910,249 | 2026-09-22 03:49:08.581350103 |
| `/home/yurasik/infra/llama-gguf-experimental/logs/laguna-s-2.1-gguf-20260922T034954Z.log` | Unsuccessful 262,144 Laguna load attempt | 1,090 | 2026-09-22 03:49:55.644360259 |
| `/home/yurasik/infra/llama-gguf-experimental/logs/laguna-s-2.1-gguf-20260922T040508Z.log` | Successful 204,800 Laguna benchmark log | 4,655,374 | 2026-09-22 13:14:23.168668471 |
| `/home/yurasik/infra/rabbit-logger/proxy.py` | OpenAI-compatible request/response logger | 24,679 | 2026-09-18 04:49:31.379633838 |
| `/home/yurasik/infra/rabbit-logger/logs/rabbit-raw.jsonl` | Raw proxy log (not modified/read wholesale) | 500,551,216 | 2026-09-22 20:36:51.756776625 |
| `/home/yurasik/infra/rabbit-logger/logs/rabbit.log` | Proxy service log | 188,611,745 | 2026-09-22 20:36:51.698777649 |

The pinned llama.cpp source is under `/home/yurasik/infra/llama-gguf-experimental/runtime/llama.cpp`; its commit/build details are in section 3.

### `nano:/home/yurasik/models`

| Path | Purpose | Bytes | mtime UTC |
|---|---|---:|---|
| `/home/yurasik/models/Qwen3.8-Flash-Next-GGUF/download-UD-Q4_K_XL.log` | GGUF download log | 548 | 2026-09-18 19:39:04.367267889 |
| `/home/yurasik/models/Qwen3.8-Flash-Next-GGUF/download-UD-Q4_K_XL.pid` | Historical downloader PID file | 7 | 2026-09-18 11:17:36.336482363 |
| `/home/yurasik/models/Laguna-S-2.1-GGUF/download-UD-Q6_K_XL.log` | GGUF download log | 544 | 2026-09-18 19:20:45.229781071 |
| `/home/yurasik/models/Laguna-S-2.1-GGUF/download-UD-Q6_K_XL.pid` | Historical downloader PID file | 7 | 2026-09-18 11:31:10.372309196 |
| `/home/yurasik/models/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4/config.json` | Model configuration | 7,411,248 | 2026-09-21 15:39:19.447757489 |
| `/home/yurasik/models/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4/hf_quant_config.json` | NVFP4 quantization configuration | 6,146,797 | 2026-09-21 15:39:19.926749550 |
| `/home/yurasik/models/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4/model.safetensors.index.json` | Weight index | 16,634,043 | 2026-09-21 17:57:53.504626851 |
| `/home/yurasik/models/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4/super_v3_reasoning_parser.py` | vLLM reasoning parser plugin | 1,909 | 2026-09-21 17:52:54.585932179 |
| `/home/yurasik/models/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4/tokenizer.json` | Tokenizer | 17,077,484 | 2026-09-21 18:03:29.691181251 |
| `/home/yurasik/models/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4/tokenizer_config.json` | Tokenizer configuration | 177,209 | 2026-09-21 17:56:55.908976781 |

### `n150:/home/yurasik/livebench`

| Path | Purpose | Bytes | mtime UTC |
|---|---|---:|---|
| `/home/yurasik/livebench/Dockerfile` | Pinned LiveBench client build and timeout patch | 938 | 2026-09-21 05:55:04.268861452 |
| `/home/yurasik/livebench/run-coding.sh` | Model detection, YAML generation, Docker run command | 5,856 | 2026-09-22 14:25:02.778591304 |
| `/home/yurasik/livebench/reset-and-run-all.sh` | Full-run orchestration helper | 1,940 | 2026-09-21 07:22:20.710380642 |
| `/home/yurasik/livebench/config/Qwen3.8-Flash-Next-NVFP4.yaml` | Qwen NVFP4 request config | 246 | 2026-09-21 07:23:03.913609903 |
| `/home/yurasik/livebench/config/qwen3.8-flash-next-gguf.yaml` | Qwen GGUF request config | 244 | 2026-09-21 14:14:27.662809241 |
| `/home/yurasik/livebench/config/laguna-s-2.1-gguf.yaml` | Laguna request config | 188 | 2026-09-22 04:09:49.926107834 |
| `/home/yurasik/livebench/config/nvidia_nemotron-3-super.yaml` | Nemotron request config | 263 | 2026-09-22 14:26:23.500781122 |

Result/state paths and line counts are inventoried in section 6. `hf-cache` contains dataset/cache artifacts but no additional experiment launcher.

## 12. Final summary

| Model | Backend | Quant | Model size GiB | Server version | Context | Parallel | LiveBench overall | LCB_generation | coding_completion | Wall time | Output tokens | Errors | Max-token truncations |
|---|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Qwen3.8-Flash-Next NVFP4 | vLLM | ModelOpt NVFP4 + PLE | 108.029 | `0.1.dev20073+g8e685d198` | 262,144 | 4 | 77.6 | 69.231 | 86.0 | 06:21:26.776 | 1,563,453 | 15 | 20 records >=32,768; exact finish-reason truncation flag not found |
| Qwen3.8-Flash-Next GGUF | llama.cpp | UD-Q4_K_XL | 103.688 | `0.4.1-dev` build 11043, `18a04f09...` | 262,144 | 4 | 80.6 | 69.231 | 92.0 | 07:35:47.147 | 639,747 | 14 | 14 (server log; JSON usage is zero for these errors) |
| Laguna S 2.1 GGUF | llama.cpp | UD-Q6_K_XL | 99.726 | `0.4.1-dev` build 11043, `18a04f09...` | 204,800 | 4 | 67.0 | 82.051 | 52.0 | 08:56:05.703 | 1,227,729 | 0 | 0 |
| NVIDIA Nemotron 3 Super 120B-A12B | vLLM | NVFP4 (`modelopt_mixed`) | 74.802 | `0.27.1` | 204,800 | 4 | 65.8 | 75.641 | 56.0 | 06:35:05.241 | 1,049,505 | 0 | 15 |