# LiveBench Coding comparison on an NVIDIA GB10 / DGX Spark-class system

I tested four large local coding-model configurations on the **NVIDIA GB10 Grace Blackwell platform**.

The physical machine is an **HP ZGX Nano G1n AI Station**, HP's OEM counterpart to NVIDIA DGX Spark. It uses the same NVIDIA GB10 Grace Blackwell Superchip with a 20-core Arm CPU, Blackwell GPU, 128 GB coherent unified LPDDR5x memory and 273 GB/s memory bandwidth.

A separate Intel N150 machine ran the LiveBench client.

Configuration: LiveBench Coding release 2024-11-25, 128 questions, four concurrent OpenAI-compatible requests, 32,768 max output tokens.

Key results:
- Qwen3.8 Flash Next GGUF: 80.6 overall
- Qwen3.8 Flash Next NVFP4: 77.6
- Laguna S 2.1 Q6: 67.0
- NVIDIA Nemotron 3 Super 120B-A12B NVFP4: 65.8

Nemotron sustained about 44.8–45.2 generated tokens/s aggregate with four concurrent requests. At ~200k context × 4, Linux reported about 120/121 GiB used and ~2.8 GiB swap occupied; vmstat showed essentially no active swap churn during inference.

Full methodology, scripts and results:
https://github.com/YuriiSokolenko/hp-gb10-local-llm-benchmarks
