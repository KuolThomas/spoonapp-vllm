FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Python deps (pin for vLLM 0.5.5 compatibility)
# - transformers/tokenizers pin fixes: AttributeError: *Tokenizer has no attribute all_special_tokens_extended
# - outlines pin kept
# - pyairports added + stubbed because outlines sometimes expects it but pip install can be weird
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir \
      "vllm==0.5.5" \
      "outlines==0.0.46" \
      "transformers==4.46.3" \
      "tokenizers==0.20.3" \
      "huggingface_hub>=0.26.0" \
      "accelerate>=0.33.0" \
      "pyairports==0.0.1"

# --- FIX: ensure pyairports is importable even if only dist-info was installed ---
RUN python3 - <<'PY'
import os, site
sp = site.getsitepackages()[0]
pkg = os.path.join(sp, "pyairports")
os.makedirs(pkg, exist_ok=True)
with open(os.path.join(pkg, "__init__.py"), "w") as f:
    f.write("# stub package for outlines dependency\n")
with open(os.path.join(pkg, "airports.py"), "w") as f:
    f.write("AIRPORT_LIST = []\n")
print("Ensured pyairports module exists at:", pkg)
PY
# -------------------------------------------------------------------------------

WORKDIR /workspace

# Copy entrypoint (downloads model if needed + starts vLLM)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
