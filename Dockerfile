FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install \
      "vllm==0.5.5" \
      "outlines==0.0.46" \
      "huggingface_hub>=0.23.0" \
      "transformers>=4.44.0" \
      "accelerate>=0.33.0" \
      "pyairports==0.0.1"

# --- FIX: ensure pyairports is importable even if only dist-info was installed ---
RUN python3 - <<'PY'
import os, site
sp = site.getsitepackages()[0]
pkg = os.path.join(sp, "pyairports")
os.makedirs(pkg, exist_ok=True)
open(os.path.join(pkg, "__init__.py"), "w").write("# stub\n")
open(os.path.join(pkg, "airports.py"), "w").write("AIRPORT_LIST = []\n")
print("Ensured pyairports module exists at:", pkg)
PY
# -------------------------------------------------------------------------------

WORKDIR /workspace

# Keep container alive if vLLM fails (prevents RunPod from instantly killing SSH)
CMD ["bash", "-lc", "python3 -m vllm.entrypoints.openai.api_server --host 0.0.0.0 --port 8000 --model /workspace/models/llama-3.1-8b-instruct --dtype auto --max-model-len 8192 || (echo 'vLLM crashed; keeping container alive for debugging' && tail -f /dev/null)"]
