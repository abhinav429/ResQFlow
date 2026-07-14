#!/usr/bin/env bash
# Start ResQFlow: API + UI on one port (default 8000).
# Usage:
#   ./start.sh              # foreground (Ctrl+C to stop)
#   ./start.sh --background # detach into tmux session resqflow
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
RUN_CMD="cd \"$ROOT/backend\" && source \"$ROOT/.venv/bin/activate\" && uvicorn main:app --reload --host 0.0.0.0 --port $API_PORT"

if [[ "${1:-}" == "--background" ]]; then
  SESSION_NAME="resqflow"
  if tmux -f /exec-daemon/tmux.portal.conf has-session -t "=$SESSION_NAME" 2>/dev/null; then
    echo "ResQFlow already running in tmux session: $SESSION_NAME"
  else
    tmux -f /exec-daemon/tmux.portal.conf new-session -d -s "$SESSION_NAME" -c "$ROOT/backend" -- "${SHELL:-bash}" -l
    tmux -f /exec-daemon/tmux.portal.conf send-keys -t "$SESSION_NAME:0.0" "$RUN_CMD" C-m
    echo "Started ResQFlow in tmux session: $SESSION_NAME"
  fi
else
  cleanup() {
    [[ -n "${API_PID:-}" ]] && kill "$API_PID" 2>/dev/null || true
  }
  trap cleanup EXIT INT TERM
  eval "$RUN_CMD" &
  API_PID=$!
fi

for _ in $(seq 1 30); do
  if curl -sf "http://127.0.0.1:${API_PORT}/health" >/dev/null 2>&1; then
    break
  fi
  sleep 0.5
done

if ! curl -sf "http://127.0.0.1:${API_PORT}/health"; then
  echo
  echo "ERROR: ResQFlow did not become healthy on port ${API_PORT}."
  exit 1
fi
echo
echo
echo "ResQFlow is running on port ${API_PORT} inside this environment."
echo
echo "  Operations UI: http://localhost:${API_PORT}/index.html"
echo "  Digital twin:  http://localhost:${API_PORT}/graph.html"
echo "  API health:    http://localhost:${API_PORT}/health"
echo
echo "IMPORTANT (cloud / remote dev):"
echo "  localhost:${API_PORT} here is the VM, not your laptop."
echo "  In Cursor, open the Ports panel and forward port ${API_PORT},"
echo "  then use the forwarded URL (or open via Cloud Desktop browser)."
echo
echo "Digital twin works immediately (demo graph) or after Start scenario on the UI."
if [[ "${1:-}" == "--background" ]]; then
  echo "Running in background (tmux session: resqflow)."
else
  echo "Press Ctrl+C to stop."
  wait
fi
