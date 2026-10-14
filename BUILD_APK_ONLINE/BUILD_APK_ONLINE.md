# Build the RESQ-MITRA Android APK on GitHub

This repository includes a GitHub Actions workflow at `.github/workflows/build-apk.yml`. The ZIP contains source code, not a prebuilt APK. GitHub builds the APK when the workflow succeeds.

## Steps

1. Create a GitHub repository.
2. Extract this ZIP and upload the **contents** of `RESQMITRA_GITHUB_READY` to the repository root. Confirm `pubspec.yaml`, `lib/`, and `.github/` are directly at the root.
3. Commit and push to `main` or `master`. You can also run it manually under **Actions → Build RESQ-MITRA Android APK → Run workflow**.
4. Open the completed workflow run and download the `RESQ-MITRA-release-apk` artifact. Extract the artifact ZIP to obtain `app-release.apk`.

The workflow uses Java 17 and Flutter stable, generates Android platform files, adds Internet and location permissions, resolves packages, and runs `flutter build apk --release`.

## Firebase configuration

The app deliberately disables authentication and SOS submission if Firebase initialization fails. To enable those features, create a Firebase project, register the Android app, configure FlutterFire for the generated Android application ID, add the generated `lib/firebase_options.dart` and platform configuration as appropriate, and update `main.dart` to initialize with `DefaultFirebaseOptions.currentPlatform`. Never commit service-account credentials. The workflow excludes no Firebase configuration by itself; ensure you only commit safe client configuration.

## Important safety and feature limits

- A successful APK build does not prove that Firebase authentication, Firestore rules, GPS, or SOS delivery works. Test those separately.
- The app currently writes an emergency record to Firestore when Firebase is configured; it does not implement guaranteed responder alert delivery or responder acceptance.
- Do not use this prototype as the sole means of contacting emergency services.
