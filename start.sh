#!/usr/bin/env bash
# Start ResQFlow backend (digital twin API) + static UI server.
# Usage: ./start.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ ! -d .venv ]]; then
  echo "Creating virtualenv..."
  python3 -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate
pip install -q -r requirements.txt

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example (optional: add AICREDITS_API_KEY)."
fi

API_PORT="${PORT:-8000}"
UI_PORT="${UI_PORT:-5500}"

cleanup() {
  [[ -n "${API_PID:-}" ]] && kill "$API_PID" 2>/dev/null || true
  [[ -n "${UI_PID:-}" ]] && kill "$UI_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "Starting API on http://localhost:${API_PORT} ..."
(cd "$ROOT/backend" && uvicorn main:app --reload --host 0.0.0.0 --port "$API_PORT") &
API_PID=$!

echo "Starting UI on http://localhost:${UI_PORT} ..."
python3 -m http.server "$UI_PORT" --bind 0.0.0.0 &
UI_PID=$!

# Wait until health responds (or fail after ~15s)
for _ in $(seq 1 30); do
  if curl -sf "http://127.0.0.1:${API_PORT}/health" >/dev/null 2>&1; then
    break
  fi
  sleep 0.5
done

if ! curl -sf "http://127.0.0.1:${API_PORT}/health"; then
  echo
  echo "ERROR: API did not become healthy on port ${API_PORT}."
  exit 1
fi
echo
echo
echo "ResQFlow is running:"
echo "  UI:           http://localhost:${UI_PORT}/index.html"
echo "  Digital twin: http://localhost:${UI_PORT}/graph.html"
echo "  API health:   http://localhost:${API_PORT}/health"
echo
echo "Open the UI, click Start scenario, then Digital twin."
echo "Press Ctrl+C to stop."

wait
