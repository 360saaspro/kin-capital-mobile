# Kin Banking — Powered by Kin Capital Rails

A Caribbean remittance and digital banking app, backed by the **Kin Capital Rails** agentic AI infrastructure layer.

## Architecture

```
┌──────────────────────────────────────────────────┐
│              Kin Banking (Flutter)                │
│  ┌─────────┐  ┌──────────┐  ┌───────────────┐   │
│  │ Auth    │  │ Home     │  │ Send Flow     │   │
│  │ Screens │  │ Screen   │  │ (Recipients →  │   │
│  │         │  │ + Credit │  │  Amount → Proc.│   │
│  │         │  │ Callout  │  │  → Confirm)    │   │
│  └─────────┘  └──────────┘  └───────────────┘   │
│  ┌──────────────────────────────────────────┐    │
│  │  Kin Capital Rails Screen (Dashboard)    │    │
│  │  Credit score · Risk factors · Routing   │    │
│  └──────────────────────────────────────────┘    │
└───────────────────────┬──────────────────────────┘
                        │ HTTP REST
                        ▼
┌──────────────────────────────────────────────────┐
│        Kin Capital Rails (FastAPI Backend)        │
│  /health · /ingest · /ledger · /credit-offer     │
│  /risk-score · /route-transfer · /orchestrate    │
└──────────────────────────────────────────────────┘
```

## New Files Added

| File | Purpose |
|---|---|
| `lib/services/api_service.dart` | HTTP client — all 8 endpoints |
| `lib/models/api_models.dart` | Response DTOs matching FastAPI schemas |
| `lib/services/app_config.dart` | Singleton for entity ID |
| `lib/screens/capital_rails/kin_capital_rails_screen.dart` | Credit dashboard with score, risk, routing |

## Modified Files

| File | Change |
|---|---|
| `lib/main.dart` | Added `AppConfig` init, `--dart-define=ENTITY_ID` support |
| `lib/screens/home/home_screen.dart` | Live ledger balance, credit callout, entity greeting |
| `lib/screens/send/send_amount_screen.dart` | Live routing fee display via `/route-transfer` |
| `lib/screens/auth/login_screen.dart` | Entity ID input field, demo skip via Face ID |
| `lib/screens/auth/onboarding_screen.dart` | Removed entityId parameter (uses AppConfig) |
| `lib/screens/auth/signup_screen.dart` | Removed entityId parameter |
| `lib/screens/auth/biometric_setup_screen.dart` | Removed entityId parameter |
| `lib/screens/main_screen.dart` | Simplified, uses AppConfig internally |
| `pubspec.yaml` | Added `http: ^1.2.0` dependency |

## Running

### 1. Start the backend

```bash
cd /path/to/kin-capital-rails
# Deterministic mode (default, no LLM needed)
uvicorn app:app --reload --port 8000

# Agentic mode (with Ollama local model)
ORCHESTRATOR_MODE=agentic \
  IMPALA_BASE_URL=http://localhost:11434/v1 \
  IMPALA_API_KEY=ollama \
  IMPALA_MODEL=llama3.2:3b \
  uvicorn app:app --reload --port 8000
```

### 2. Run the Flutter app

```bash
cd kin_app_antigravity

# Default (emulator/localhost)
flutter run

# With custom API host (physical device / Antigravity)
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000

# With custom entity ID
flutter run --dart-define=ENTITY_ID=maria_trader_sps_001
```

### Google Antigravity

For Antigravity testing:
1. Ensure the FastAPI backend is accessible (e.g. ngrok or LAN IP)
2. Build with: `flutter build web --dart-define=API_BASE_URL=<your-url>`
3. Deploy the web build to Antigravity

## Branding

Brand assets from the original zip are preserved at `assets/images/kin_logo.png` (226×512, full-colour Kin logo). App icons are set per-platform in `ios/` and `android/`.

## Demo Flow

1. Onboard / login with entity ID `maria_trader_sps_001`
2. Home screen shows live balance from `/ledger`
3. Credit callout card shows score & limit from `/credit-offer`
4. Tap credit badge → full **Kin Capital Rails** dashboard
5. Send flow → live routing fee from `/route-transfer`
6. Orchestration button runs full agentic loop