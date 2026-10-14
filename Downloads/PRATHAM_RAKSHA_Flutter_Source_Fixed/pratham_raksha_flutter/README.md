# RESQ-MITRA Flutter starter

**Tagline:** BE FIRST TO RESPOND

This project converts the supplied RESQ-MITRA specification into a Flutter starter application. It includes the animated splash screen with your supplied logo, the branded sign-in/create-account UI, emergency category dashboard, role selection, emergency details, GPS permission flow, Firebase authentication hooks, Firestore emergency-record creation, and a status screen.

## Important limitation

This is a starter implementation, **not a production-ready emergency response service**. The source prompt ends partway through the active emergency screen specification. This code implements a safe foundation from the available requirements. It does not yet implement responder matching, push-alert distribution, responder verification, live responder tracking, arrival/resolution workflow, ratings, or a trusted server-side authorization layer. Do not rely on it for real emergencies until those systems are implemented and independently tested.

The supplied original RESQ-MITRA logo is included at `assets/images/resq_mitra_logo.jpeg` and used on the splash, authentication, and home screens.

## Requirements

- Flutter SDK (stable)
- Android Studio / Android SDK or VS Code with Flutter extension
- A Firebase project for real authentication and database writes

## Run

1. Extract the ZIP.
2. Open the `resq_mitra_flutter` folder in VS Code.
3. In a terminal, run:

   ```bash
   flutter doctor
   flutter pub get
   ```

4. Configure Firebase for your app:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Ensure the generated Firebase options are initialized according to the FlutterFire setup for your project. This starter currently calls `Firebase.initializeApp()` with platform defaults; depending on your project setup, you may need to use the generated `DefaultFirebaseOptions.currentPlatform` import in `lib/main.dart`.

5. Configure Firebase Authentication (Email/Password) and Cloud Firestore in the Firebase console.
6. Set up Android location permissions in `android/app/src/main/AndroidManifest.xml`:

   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   ```

7. Run:

   ```bash
   flutter run
   ```

## Backend setup checklist

Before accepting real SOS requests:

- Configure Firestore security rules so users can create/read only authorized records.
- Prefer a trusted backend / Cloud Functions for validation, unique status transitions, eligible-responder selection, transactional assignment, and push notifications.
- Never allow clients to mark themselves verified responders.
- Implement server-side distance and category eligibility checks using verified responder status, service area, availability, and recent location.
- Add FCM token registration and server-triggered emergency notifications.
- Test failed network requests, duplicate taps, expired sessions, denied location, stale GPS, and unauthorized access.
- Add audit logging without recording passwords or unnecessary personal information.
- Add a clearly tested fallback procedure and emergency-service guidance.

## Firestore collection starting points

- `users/{uid}`: public profile fields and selected role; do not store passwords.
- `responders/{uid}`: verification status, skills, eligibility, availability, service area, and consent-based location.
- `emergencies/{sosId}`: emergency request and status.
- `assignments/{assignmentId}`: responder assignment lifecycle.

Do not deploy open Firestore rules such as `allow read, write: if true`.


## Build an APK using GitHub Actions (no local Flutter install needed)

This starter includes `.github/workflows/build-apk.yml`. Commit and push the project to the `main` branch, then open your GitHub repository and go to **Actions → Build RESQ-MITRA APK**. Open the successful workflow run and download the `RESQ-MITRA-release-apk` artifact. Extract it to get `app-release.apk`.

To commit a downloaded APK into the repository from Git Bash, copy it to the repository folder (for example, `release/app-release.apk`) and run:

```bash
git add release/app-release.apk
git commit -m "Add RESQ-MITRA release APK"
git push origin main
```

A GitHub Actions build is a convenient build path, but it does not configure Firebase, signing credentials, responder alert delivery, or production security. `flutter analyze` may expose source issues that need fixing before a successful APK is produced. For public distribution, use a proper release signing key and never commit the private keystore or passwords.
