# RESQ-MITRA Flutter conversion

This is a Flutter/Dart starter conversion of the React/TypeScript source supplied in the ZIP. It includes the main home screen, General SOS and Women SOS forms, local incident dashboard and tracking, contacts, GPS capture, Google Maps deep links, local registration/login prototype, SQLite storage, and JSON backup/import.

## Important limits

- This is a functional **local prototype**, not a live emergency dispatch system.
- SOS reports are saved only in the app's local SQLite database. They are not automatically sent to police, ambulance services, contacts, or a remote response team.
- The responder entries are default emergency contact entries, not verified live responders.
- Local login is for prototype testing only. Do not deploy it for public users. Replace it with Firebase Authentication or another secure server-backed identity provider.
- Password hashes are stored locally for the prototype. JSON export deliberately excludes password hashes.
- JSON export is displayed in the app so it can be copied; import accepts incident records from that exported JSON structure. It does not sync devices.
- Google Maps opens using a web link; a native embedded map and live responder tracking are not included.

## Generate Android/iOS platform folders

Install Flutter and Android Studio, extract this folder, open a terminal in it, then run:

```bash
flutter doctor
flutter create --platforms=android,ios .
flutter pub get
```

If `flutter create` says it will overwrite files, keep the existing `lib/` and `pubspec.yaml`. On a Windows PC, Android builds are supported; iOS builds require macOS and Xcode.

## Android location permissions

Open `android/app/src/main/AndroidManifest.xml` and add these lines inside the root `<manifest>` element and before `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

The app requests location permission when the user taps the location button. It does not request background location.

## Run and build

```bash
flutter pub get
flutter run
flutter build apk --release
```

The APK is normally generated at `build/app/outputs/flutter-apk/app-release.apk` after a successful release build.

## Database

SQLite database name: `resq_mitra.db`

Tables:

- `incidents`: incident ID, category, emergency type, description, contact information, optional coordinates, status, priority, created timestamp and user email.
- `users`: local prototype account email, name, password hash and creation timestamp.
- `responders`: default contact records.

The schema is created by `lib/services/app_database.dart` on first launch. App data is local to the device and can be cleared by uninstalling the app or clearing app storage.

## JSON structure

Export produces a versioned JSON object with `schemaVersion`, `exportedAt`, `incidents`, `responders`, and non-secret `users` fields. Example incident object:

```json
{
  "id": "PR-2026-EXAMPLE01",
  "category": "General",
  "emergencyType": "Medical emergency",
  "description": "Example report",
  "contactName": "",
  "contactPhone": "",
  "latitude": null,
  "longitude": null,
  "status": "Created",
  "priority": "High",
  "createdAt": "2026-10-12T10:00:00.000Z",
  "userEmail": ""
}
```

## Main source files

- `lib/main.dart`: Flutter UI and navigation
- `lib/models/incident.dart`: incident model and JSON/map conversion
- `lib/services/app_database.dart`: SQLite schema, local accounts, incident CRUD, responder records, JSON export/import


## Build log fix (October 2026)

The `IncidentsScreen` and `RespondersScreen` implementations were reformatted and their mismatched parentheses/braces corrected after a release build reported Dart syntax errors. Run `flutter pub get` and `flutter build apk --release` again. This environment does not have the Flutter SDK installed, so the corrected source has not been compiled here.


## RESQ-MITRA branding update
The home screen now uses the RESQ-MITRA name and the supplied logo asset at
`assets/resq_mitra_logo.png`. The SOS entry point offers General, Women, and
Children categories. Existing prototype limitations remain: reports are stored
locally and are not automatically dispatched to emergency services or live responders.
