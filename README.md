# RESQ-MITRA Flutter app

This is a Flutter/Dart starter conversion of the React/TypeScript source supplied in the ZIP. It includes the logo splash screen with running “HELP | PROTECT | SUPPORT | TOGETHER” tagline, persistent local sign-in, help-seeker/volunteer role selection, blinking SOS home screen with General SOS, Women SOS and Child SOS forms, local incident dashboard and tracking, contacts, GPS capture, Google Maps deep links, local registration/login prototype (name, phone, email, password), SQLite storage, and JSON backup/import.

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

SQLite database name: `pratham_raksha.db`

Tables:

- `incidents`: incident ID, category, emergency type, description, contact information, optional coordinates, status, priority, created timestamp and user email.
- `users`: local prototype account email, name, phone, password hash and creation timestamp.
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

## SOS emergency types

The SOS report form provides category-specific emergency types:

- **General SOS:** Medical emergency, Accident, Fire, Flood, Rescue, Evacuation, Missing person, Other.
- **Women SOS:** Immediate danger, Harassment, Unsafe situation, Escort assistance, Medical emergency, Safe shelter, Others.
- **Child SOS:** Child in Immediate danger, Missing child, Medical emergency, Lost child, Child abuse or threat, Unsafe situation, Rescue assistance, Others.

Every SOS report includes a required description field. For **Other/Others**, the field is labelled to request an explanation. The selected emergency type is saved in `incidents.emergencyType`; the user's explanation is saved in `incidents.description` in the existing SQLite database, so no additional database column or migration is needed.


## Emergency confirmation and DO NOT CALL

The SOS form now leads to an emergency confirmation screen with category, selected emergency type, description, GPS location when available, and a **DO NOT CALL** checkbox. Confirming saves the preference in the `incidents.doNotCall` SQLite field and shows it in incident tracking. SQLite database version 3 adds this field with a migration for existing installations.

**Dispatch limitation:** this is still a local prototype. The confirmation screen does not send a network signal or notify nearby responders. A real responder notification flow requires a secure backend, responder accounts/location/availability, push notifications, and delivery/acknowledgement handling. The DO NOT CALL preference is stored locally and cannot yet control external responders or call systems.


## Blood-needed SOS

General SOS includes a **Blood needed** emergency type. When selected, the form asks for one of the eight blood groups (A+, A-, B+, B-, AB+, AB-, O+, O-). The selected blood group is stored in the incident `bloodGroup` SQLite column and displayed on the emergency confirmation and incident tracking screens. Existing databases migrate to schema version 4 automatically.
