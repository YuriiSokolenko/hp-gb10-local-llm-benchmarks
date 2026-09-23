# Four local coding LLM configs on one NVIDIA GB10: Qwen3.8 Flash Next vs Laguna S 2.1 vs Nemotron 3 Super

I ran the same LiveBench Coding release (2024-11-25, 128 questions) against four locally served configurations on one GB10 with 128 GB unified memory. The benchmark client ran on a separate N150 box. Concurrency was 4 and max output was 32,768 tokens.

| Model | Overall | LCB generation | Completion |
|---|---:|---:|---:|
| Qwen3.8 Flash Next GGUF | 80.6 | 69.231 | 92 |
| Qwen3.8 Flash Next NVFP4 | 77.6 | 69.231 | 86 |
| Laguna S 2.1 Q6 | 67.0 | 82.051 | 52 |
| Nemotron 3 Super NVFP4 | 65.8 | 75.641 | 56 |

The generation/completion split surprised me. Laguna had the strongest LCB_generation score, but Qwen dominated completion.

I also included timing, token counts, memory/swap behavior, thermals, model sizes and runner scripts in the repo.

Reproduction/report:
https://github.com/YuriiSokolenko/hp-gb10-local-llm-benchmarks
