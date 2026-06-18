# Spill FastAPI Backend

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Firebase auth middleware

All write requests (`POST`, `PUT`, `PATCH`, `DELETE`) support two modes:

- guest writes with no `Authorization` header, which are attributed to a stable `anonymous-<hash>` ID derived from the client IP,
- authenticated writes with a Firebase ID token in:

```text
Authorization: Bearer <firebase-id-token>
```

When the header is present, the middleware verifies the token using `firebase-admin` and stores `uid` in `request.state.user_id`.

Anonymous ID generation uses `ANONYMOUS_USER_SALT` when set and falls back to `spill-anon`.

## Firestore schema

Collection: `spills`
- `lat`: number
- `lng`: number
- `user_id`: string
- `timestamp`: server timestamp
- `message`: string
- `image_url`: string | null

Collection: `spill_comments`
- `spill_id`: string (references `spills/{spill_id}`)
- `user_id`: string
- `message`: string
- `timestamp`: server timestamp

## Write endpoints

- `POST /spill/create`
- `POST /spill/{spill_id}/comments`

## Docker (ARM64 OCI)

Build ARM64 image for OCI Ampere:

```bash
docker buildx build --platform linux/arm64 -t spill-backend:arm64 backend
```

Run:

```bash
docker run --rm -p 8000:8000 \
  -e FIREBASE_SERVICE_ACCOUNT_PATH=/secrets/firebase-service-account.json \
  -v "$PWD/firebase-service-account.json:/secrets/firebase-service-account.json:ro" \
  spill-backend:arm64
```
