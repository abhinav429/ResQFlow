# ResQFlow: Closed-Loop Cyber-Physical Orchestration for Disaster Resource Dispatch

Single-file orchestration UI in `index.html` (brand: **ResQFlow**).

The **Digital twin** (knowledge graph explorer + twin-grounded evidence on each allocation) needs the FastAPI backend running. If that process is stopped, the UI falls back to local text and shows “backend offline” for twin features.

## Quick start (recommended)

From the repo root:

```bash
./start.sh
```

This will:

1. Create `.venv` and install `requirements.txt` if needed
2. Copy `.env.example` → `.env` if missing
3. Start the API on **http://localhost:8000**
4. Serve the UI on **http://localhost:5500**

Then open:

- **Operations UI:** http://localhost:5500/index.html  
- **Digital twin:** http://localhost:5500/graph.html  

Flow: **Start scenario** → **Digital twin** (or header link).

Health check:

```bash
curl http://localhost:8000/health
```

Expected: `{"status":"ok","service":"resqflow-api",...,"graph":"networkx","agents":"council"}`

## Manual backend setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Optional: set AICREDITS_API_KEY in .env for AI briefing/report
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

In another terminal (repo root):

```bash
python3 -m http.server 5500
```

### Backend status in the UI

The **Summary** panel shows:

- **Connected (aicredits)** — LLM key loaded; Briefing/Report use AI
- **Connected (local text only)** — backend up but no API key
- **Offline** — frontend uses built-in local text; digital twin evidence unavailable

## AICredits setup (OpenAI-compatible)

Put your key in **`.env`** at the repo root (copy from `.env.example`):

```env
LLM_PROVIDER=aicredits
AICREDITS_API_KEY=sk-your-aicredits-key
AICREDITS_BASE_URL=https://api.aicredits.in/v1
AICREDITS_MODEL=gpt-4o-mini
```

Restart the backend after editing `.env`.

## Knowledge graph (digital twin)

When the backend is running, each allocation fetches **graph evidence** from `POST /graph/evidence`:

- **Evidence path** — base → resource → risk zone → incident
- **Ripple check** — competing incidents, fuel pressure, coverage gaps
- **2-hop subgraph** — neighborhood around the incident

Traces save to `data/traces/` as JSON for audit replay.

### Knowledge Graph Explorer (`graph.html`)

1. Run `./start.sh` (or backend + static server as above)
2. Open **http://localhost:5500/index.html** → **Start scenario**
3. Click **Digital twin** / **Graph view**
4. Pan/zoom the graph, pick incident/trace, inspect evidence path and ripple panel

**Endpoints:** `POST /graph/full`, `GET /graph/traces`, `GET /graph/traces/{id}`

### Phase 4 — Agent council

With **Agent council** enabled (Controls checkbox), each allocation runs three graph-grounded reviewers before commit:

- **Medical** — capability & urgency  
- **Logistics** — fuel & competing coverage  
- **Route** — risk exposure  

`POST /agents/council` returns merged score deltas; the UI re-ranks candidates.

## Run without backend

Open `index.html` only (or static server alone). No API key required. Briefing and Report use local rule-based text. **Digital twin evidence and the explorer’s server-side NetworkX analysis will not work** until the API is started.

## Quick test

1. Click **Start scenario**.
2. Watch the **Operations map**: bases, risk zones, incidents, routes.
3. Change **Strategy** and use **Preview** under **Strategy compare**.
4. Use **Quick request** + **Add** for a one-line request, or **Add incident**.
5. Read **Latest allocation** for scores, graph evidence path, and ripple notes.
6. Under **Summary**, use **Briefing** and **Report** (backend optional).
7. Open **Digital twin** to explore the live knowledge graph.
