# chargenet_shared

Shared foundation for ChargeNET Flutter apps: theme tokens, widgets, API client, and auth.

## What's included (S0–S4)

| Layer | Contents |
|-------|----------|
| Theme | Colors, spacing, radii, Inter typography, mobile/desktop `ThemeData` |
| Widgets | `CnButton`, `CnCard`, `CnTextField`, `CnStatusBadge`, `CnLoading`, `CnErrorView` |
| API | Dio client, JWT interceptor, `ApiException`, `AppConfig` base URL |
| Auth | Login/register screens, `authProvider`, token storage, role guards via `go_router` |

## Running the apps

```powershell
# Start backend (Docker) first — API on http://localhost:5000

cd chargeNET/UI/chargenet_mobile   # or chargenet_desktop
flutter pub get
flutter run
```

### API base URL

| Target | Default URL |
|--------|-------------|
| Windows desktop | `http://localhost:5000` |
| Android emulator | `http://10.0.2.2:5000` |
| Physical device | Your machine's LAN IP |

Override at build time:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000
```

## Manual testing checklist

1. **Register (mobile)** — open mobile app → *Create driver account* → fill form → lands on home shell.
2. **Login (desktop)** — register an admin via Swagger/API, or use a seeded account once passwords are fixed → desktop login → home shell.
3. **Role guard** — log in as Driver on desktop → *Access denied* screen, not a crash.
4. **Session restore** — sign in → hot restart app → still authenticated.
5. **API test** — on home shell, tap *Test API — load stations* (requires backend running).
6. **Widget gallery** — palette icon in app bar (debug builds) shows all shared widgets.
7. **401 logout** — expire/revoke token server-side → next API call clears session and returns to login.

### Seeded passwords

Seed data may have placeholder password hashes. Either **register a new user** via the mobile app or fix hashes in `ChargeNetSeed.cs` before testing login with seeded accounts.

## Automated tests

```powershell
cd chargeNET/UI/chargenet_shared
flutter test

cd ../chargenet_mobile
flutter test

cd ../chargenet_desktop
flutter test
```

Static analysis across all three packages:

```powershell
flutter analyze
```

## Token storage

- **iOS/Android:** `flutter_secure_storage` (encrypted)
- **Windows/macOS/Linux:** `shared_preferences` (seminar-acceptable fallback)
