I benchmarked four large local coding LLM configurations on a single NVIDIA GB10 (128 GB unified memory), using the same 128-question LiveBench Coding release and 4 concurrent requests.

Results:
• Qwen3.8-Flash-Next GGUF: 80.6 overall — 69.231 generation / 92 completion
• Qwen3.8-Flash-Next NVFP4: 77.6 — 69.231 / 86
• Laguna S 2.1 Q6: 67.0 — 82.051 / 52
• NVIDIA Nemotron 3 Super NVFP4: 65.8 — 75.641 / 56

The most interesting result was not the overall ranking. Laguna and Nemotron both beat Qwen on generation-from-scratch, while Qwen was dramatically stronger at code completion. That split matters when choosing a model for different coding-agent workloads.

I also recorded wall time, throughput, memory pressure, swap behavior, thermals and power. Nemotron, for example, sustained ~45 tok/s aggregate at four concurrent requests on the GB10, but its ~200k×4 configuration left only ~1 GiB of RAM available.

Methodology, scripts, summary data and reproducibility notes:
https://github.com/YuriiSokolenko/hp-gb10-local-llm-benchmarks

The next step is repo-level/agentic evaluation, because LiveBench Coding alone should not be treated as a universal coding-agent ranking.
