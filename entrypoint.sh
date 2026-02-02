#!/bin/bash
set -e

MODEL_DIR="/workspace/models/llama-3.1-8b-instruct"

echo "🚀 SpoonApp vLLM booting..."

# ---------------------------
# Download model only once
# ---------------------------
if [ ! -f "$MODEL_DIR/config.json" ]; then
  echo "📥 Model not found, downloading..."

  python3 - <<'PY'
import os
from huggingface_hub import snapshot_download

snapshot_download(
  repo_id="meta-llama/Meta-Llama-3.1-8B-Instruct",
  local_dir="/workspace/models/llama-3.1-8b-instruct",
  token=os.environ["HF_TOKEN"],
)
print("✅ Model download complete")
PY
else
  echo "✅ Model already cached"
fi

# ---------------------------
# Launch vLLM Server
# ---------------------------
echo "🔥 Starting vLLM OpenAI API Server..."

exec python3 -m vllm.entrypoints.openai.api_server \
  --host 0.0.0.0 \
  --port 8000 \
  --model meta-llama/Meta-Llama-3.1-8B-Instruct
