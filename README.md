# NiveshIQ

India-focused mobile stock prediction project branded as `NiveshIQ`, with:

- `flutter_app` for the Flutter client
- `backend` for the Node.js app-facing API
- `ml_service` for the Python market-data and prediction service

## What It Does

- Shows a broad Indian equity universe from the curated `Nifty 200` symbol master
- Supports symbol search, quotes, chart history, company basics, watchlists, dashboard, analytics, and stock details
- Serves 7-day model-backed predictions through the existing Flutter prediction UI contract
- Falls back to deterministic local market generation if the Python ML service is unavailable

## Project Structure

- `flutter_app/` Flutter mobile application
- `backend/` Express API consumed by the app on port `3000`
- `backend/data/nifty200.csv` supported Indian equity universe
- `ml_service/` FastAPI-based market-data and ML prediction service on port `8000`
- `stitch_neural_market_predictor/` reference design folder, intentionally ignored from git

## Setup

### 1. Python ML service

```powershell
cd C:\Users\hp\Desktop\pradeep\ml_service
python -m pip install -r requirements.txt
python -m uvicorn app:app --host 127.0.0.1 --port 8000
```

### 2. Node backend

```powershell
cd C:\Users\hp\Desktop\pradeep\backend
npm install
node src/index.js
```

Optional environment variables:

- `ML_SERVICE_BASE_URL` default: `http://127.0.0.1:8000`
- `ML_SERVICE_TIMEOUT_MS` default: `6000`
- `ML_FALLBACK_ENABLED` default: `true`

### 3. Flutter app

```powershell
cd C:\Users\hp\Desktop\pradeep\flutter_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api
```

For a physical Android phone connected by USB, use:

```powershell
adb reverse tcp:3000 tcp:3000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api
```

## Key API Endpoints

- `GET /api/health`
- `GET /api/bootstrap`
- `GET /api/symbols?query=...`
- `GET /api/quotes/:symbol`
- `GET /api/charts/:symbol?range=1M`
- `GET /api/company/:symbol`
- `GET /api/dashboard`
- `GET /api/watchlist`
- `POST /api/watchlist`
- `GET /api/market/analytics`
- `GET /api/stocks/:symbol`
- `GET /api/predictions/:symbol`

## Notes

- The Python service caches market history locally under `ml_service/cache/`.
- Trained model artifacts and prediction cache are stored under `ml_service/artifacts/`.
- The current prediction workflow is daily end-of-day focused and designed as a local prototype for Indian equities.
