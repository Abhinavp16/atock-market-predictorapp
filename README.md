# NiveshIQ

Android-only stock prediction workspace for Indian equities.

## Structure

- `flutter_app/` Android Flutter client
- `backend/` Node.js API on port `3000`
- `backend/data/nifty200.csv` supported Indian equity universe
- `backend/data/appdb.json` local development database when `DATABASE_PROVIDER=local`
- `ml_service/` Python market-data and prediction service on port `8000`

## What It Does

- Shows a broad Indian equity universe from the curated `Nifty 200` symbol list
- Supports search, quotes, charts, company data, watchlists, analytics, and predictions
- Uses a local Node backend plus a local Python ML service
- Supports JWT auth, refresh sessions, password reset, email verification, and paper trading

## Run Locally

### 1. Start the ML service

```powershell
cd C:\Users\hp\Desktop\pradeep\ml_service
python -m pip install -r requirements.txt
python -m uvicorn app:app --host 127.0.0.1 --port 8000
```

### 2. Start the backend

```powershell
cd C:\Users\hp\Desktop\pradeep\backend
npm install
node src/index.js
```

Optional backend environment variables:

- `DATABASE_PROVIDER` default: `local`, set to `mongo` for MongoDB
- `MONGODB_URI` default: `mongodb://127.0.0.1:27017`
- `MONGODB_DB_NAME` default: `niveshiq`
- `LOCAL_DB_FILE_PATH` optional local JSON database override
- `ML_SERVICE_BASE_URL` default: `http://127.0.0.1:8000`
- `ML_SERVICE_TIMEOUT_MS` default: `6000`
- `ML_FALLBACK_ENABLED` default: `true`
- `AUTH_SECRET` JWT signing secret
- `SEED_USER_PASSWORD` optional seed login password override

### 3. Run on a USB-connected Android phone

```powershell
adb reverse tcp:3000 tcp:3000
adb reverse tcp:8000 tcp:8000
cd C:\Users\hp\Desktop\pradeep\flutter_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api
```

### Seed login for local testing

- Email: `pradeep@niveshiq.in`
- Password: `password!`

## Main API Endpoints

- `GET /api/health`
- `GET /api/bootstrap`
- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`
- `POST /api/auth/verify-email`
- `GET /api/session`
- `GET /api/dashboard`
- `GET /api/symbols?query=...&sector=...&marketCapBucket=...`
- `GET /api/market/movers`
- `GET /api/compare?symbols=INFY,TCS`
- `GET /api/screener`
- `GET /api/quotes/:symbol`
- `GET /api/charts/:symbol?range=1M`
- `GET /api/company/:symbol`
- `GET /api/watchlist`
- `POST /api/watchlist`
- `DELETE /api/watchlist/:symbol`
- `GET /api/portfolio`
- `GET /api/orders`
- `POST /api/orders`
- `GET /api/trades`
- `GET /api/market/analytics`
- `GET /api/stocks/:symbol`
- `GET /api/predictions/:symbol`

## Notes

- Generated build caches, node modules, ML cache/artifacts, and debug captures are intentionally not kept in the repo.
- `backend/npm test`, `python -m unittest test_app.py`, and `flutter analyze` now provide a basic verification baseline.
- MongoDB is supported for the hardening roadmap, while `DATABASE_PROVIDER=local` keeps local development lightweight.
