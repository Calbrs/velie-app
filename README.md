# Velie

Flutter app for Velie — WhatsApp status/chat scheduling for businesses.
Talks to the Velie backend (`velie-backend` repo) at `https://velie.calbrs.com/api`.

## Environments

The API base URL is **never hardcoded** — it comes from `.env` (via
`--dart-define` / dotenv, see `lib/core/constants/app_constants.dart`):

```bash
# development (local backend + Velie_dev database)
flutter run --dart-define=API_BASE_URL=http://localhost:4000/api

# production build (what users get)
flutter run   # .env already points at https://velie.calbrs.com/api
```

## Branch Model

```
feature/*  →  develop  →  main  →  release
```

- `main` = code that is approved to ship to users
- Build/verify on `feature/*`, merge through `develop`
- Backend workflow details: see the `README.md` in the velie-backend repo

## Releasing an App Update

1. Bump `version:` in `pubspec.yaml`
2. `D:\Calbrs Projects\oci_script\deploy_apk.ps1` — builds release APK,
   uploads `velie.apk` + `version.json` to OCI Object Storage (versioned
   backups are kept as `velie_vX.Y.Z.apk`)
3. Users receive the update via the in-app updater
