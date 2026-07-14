# ResQFlow: Closed-Loop Cyber-Physical Orchestration for Disaster Resource Dispatch

Single-file orchestration UI in `index.html` (brand: **ResQFlow**).

The **Digital twin** (knowledge graph explorer + twin-grounded evidence on each allocation) needs the FastAPI backend running. If that process is stopped, the UI falls back to local text and shows “backend offline” for twin features.

## Quick start (recommended)

From the repo root:

```bash
./start.sh
```

Or keep it running in the background:

```bash
./start.sh --background
```

This will:

1. Create `.venv` and install `requirements.txt` if needed
2. Copy `.env.example` → `.env` if missing
3. Start **one server** on **http://localhost:8000** that serves both the UI and the digital-twin API

Then open (after forwarding port 8000 in Cursor **Ports**, if you are remote):

- **Operations UI:** http://localhost:8000/index.html  
- **Digital twin:** http://localhost:8000/graph.html  

**Port:** `8000` only (UI + API together). Port `5500` is no longer used.

If `localhost:8000` shows nothing on your machine, the server is still running in the cloud VM — use Cursor's **Ports** tab → forward **8000** → **Open in Browser**. Or open the URL inside the **Cloud Desktop** browser.

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

In another terminal (repo root) — only if you are not using `./start.sh`:

```bash
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The unified server also serves `index.html` and `graph.html` from the repo root on the same port.

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

1. Run `./start.sh` (or `./start.sh --background`)
2. Open **http://localhost:8000/index.html** → **Start scenario** (optional for live sync)
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
