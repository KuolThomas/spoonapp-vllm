FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Python deps (pin versions for stability)
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install \
      "vllm==0.5.5" \
      "outlines==0.0.46" \
      "huggingface_hub>=0.23.0" \
      "transformers>=4.44.0" \
      "accelerate>=0.33.0"

# Workdir
WORKDIR /workspace

# Default command: start vLLM OpenAI-compatible server
# You will pass env vars + model path in RunPod.
CMD ["bash", "-lc", "python3 -m vllm.entrypoints.openai.api_server --host 0.0.0.0 --port 8000 --model /workspace/models/llama-3.1-8b-instruct --dtype auto --max-model-len 8192"]
