# Build the Android APK online (no Flutter installation on your own computer)

This repository includes a GitHub Actions workflow at `.github/workflows/android-apk.yml`. It builds the Android APK on GitHub's hosted runner. The ZIP is source code, not an APK; the APK is created only after the workflow succeeds.

## Steps

1. Sign in or create an account at https://github.com.
2. Create a new repository, for example `pratham-raksha-flutter`. For easiest setup, choose **Private**.
3. Extract this ZIP on a computer, then upload all files and folders (including the hidden `.github` folder) to the repository's `main` branch. Make sure `.github/workflows/android-apk.yml` is included. Alternatively, use Git from the extracted project folder to push the project.
4. Open the repository's **Actions** tab. Select **Build PRATHAM-RAKSHA Android APK**. If prompted, enable workflows. Click **Run workflow**.
5. Wait for the run to finish. A green check mark means the workflow completed. If it fails, open the run and inspect the failed step's log; the source may need a code or dependency fix.
6. In the completed run, find **Artifacts** and download `pratham-raksha-android-apk`.
7. Extract the downloaded artifact ZIP. It contains `app-release.apk`.
8. Transfer `app-release.apk` to your Android phone, tap it, and approve Android's install prompt if needed.

## Important safety and feature limits

- This builds the current local prototype; it does not turn it into a connected emergency-dispatch system.
- Incident data and prototype accounts are stored on the device. There is no cloud sync or automatic alert delivery to police, ambulance, or a staffed responder centre.
- Test only with sample incidents until emergency delivery, privacy, security, and responder workflows have been implemented and validated.
- Do not commit passwords, API keys, or real users' emergency/location data to the repository.
