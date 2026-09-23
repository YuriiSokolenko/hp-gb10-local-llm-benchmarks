# LiveBench Coding comparison on a single NVIDIA GB10

I tested four large local coding-model configurations on one GB10 using a separate N150 machine as the LiveBench client.

Configuration: LiveBench Coding release 2024-11-25, 128 questions, four concurrent OpenAI-compatible requests, 32,768 max output tokens.

Key results:
- Qwen3.8 Flash Next GGUF: 80.6 overall
- Qwen3.8 Flash Next NVFP4: 77.6
- Laguna S 2.1 Q6: 67.0
- NVIDIA Nemotron 3 Super 120B-A12B NVFP4: 65.8

Nemotron sustained about 44.8–45.2 generated tokens/s aggregate with four concurrent requests. At ~200k context × 4, Linux reported about 120/121 GiB used and ~2.8 GiB swap occupied; vmstat showed essentially no active swap churn during inference.

Full methodology, scripts and results:
https://github.com/YuriiSokolenko/hp-gb10-local-llm-benchmarks
