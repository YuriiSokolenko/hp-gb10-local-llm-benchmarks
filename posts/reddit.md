# Four local coding LLM configs on an NVIDIA GB10 / DGX Spark-class computer

I benchmarked four locally served coding-model configurations on an **NVIDIA GB10 Grace Blackwell platform**, the same compute platform used by NVIDIA DGX Spark.

My actual machine is the **HP ZGX Nano G1n AI Station**, essentially HP's OEM counterpart to DGX Spark: NVIDIA GB10 Grace Blackwell, 20-core Arm CPU, Blackwell GPU, 128 GB coherent unified LPDDR5x, 273 GB/s memory bandwidth and 4 TB NVMe.

The same LiveBench Coding release (2024-11-25, 128 questions) was used for all runs. The benchmark client ran on a separate N150 box. Concurrency was 4 and max output was 32,768 tokens.

| Model | Overall | LCB generation | Completion |
|---|---:|---:|---:|
| Qwen3.8 Flash Next GGUF | 80.6 | 69.231 | 92 |
| Qwen3.8 Flash Next NVFP4 | 77.6 | 69.231 | 86 |
| Laguna S 2.1 Q6 | 67.0 | 82.051 | 52 |
| Nemotron 3 Super NVFP4 | 65.8 | 75.641 | 56 |

The generation/completion split surprised me. Laguna had the strongest LCB_generation score, while Qwen dominated completion.

I also included timing, token counts, memory/swap behavior, thermals, model sizes and runner scripts in the repo.

Reproduction/report:
https://github.com/YuriiSokolenko/hp-gb10-local-llm-benchmarks
