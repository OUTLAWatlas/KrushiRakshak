# Krushi Rakshak

Offline-first precision agronomy assistant. Krushi Rakshak diagnoses crop diseases on-device using a bundled TensorFlow Lite model, scans seed packets with on-device OCR, and speaks critical alerts in English/Hindi/Marathi for field use without reliable connectivity.

## How it works
- Crop Doctor pipeline: camera preview -> quantized TFLite model (`assets/models/model_quantized.tflite`) -> label lookup -> severity rule -> bottom sheet + TTS for critical detections.
- Seed Scanner pipeline: capture packet photo -> Google ML Kit OCR -> simple heuristics (expired / verified / unknown) -> status chip.
- Localization: `LocalizationService` switches locale (en/mr/hi) and drives `AppTheme` so colors and text adapt per language.
- Persistence: `DatabaseService` (Hive) stores user profile/settings; `LedgerService` manages app state; offline by default.
- Voice feedback: `TtsService` speaks alerts so a farmer can keep working hands-free.

## Project structure (high level)
- [lib/main.dart](lib/main.dart): app bootstrap, routes, providers, locale/theme wiring.
- [lib/modules/](lib/modules): feature screens (dashboard, onboarding, profile, auth).
- [lib/home_screen.dart](lib/home_screen.dart): tabbed Crop Doctor + Seed Scanner UX.
- [lib/core/services](lib/core/services): shared services (TFLite, OCR, localization, database, ledger, theme helpers).
- [assets/models](assets/models): quantized model + labels used by TFLite.
- [assets/images](assets/images) & [assets/icons](assets/icons): UI assets and splash/launcher art.

## What it does
- On-device Crop Doctor: camera stream classification with the quantized model + localized labels; shows severity chips and plays TTS for critical detections.
- Seed Scanner: captures a packet photo, runs Google ML Kit OCR, and flags expired or verified seeds based on label heuristics.
- Offline-ready: ships with models, labels, and icons in [assets/models](assets/models), [assets/images](assets/images), and [assets/icons](assets/icons).
- Multilingual UI: supports en, mr, hi via `LocalizationService`; theming is locale-aware.
- Lightweight data layer: Hive-backed `DatabaseService` for profile/settings and `LedgerService` for in-app state.

## Tech stack
- Flutter 3.1+ (Dart >=3.1.0)
- Provider for app state
- Camera + TFLite Flutter for on-device inference
- Google ML Kit Text Recognition for OCR
- Hive for local storage
- Flutter TTS for spoken alerts

## Prerequisites
- Flutter SDK installed and on PATH
- Android SDK/NDK for building the app; an Android device or emulator

## Setup
1) Install deps
```bash
flutter pub get
```
2) Generate native splash (optional, after asset changes)
```bash
flutter pub run flutter_native_splash:create
```
3) Run on a device/emulator
```bash
flutter run
```

## Build an APK
Release build is recommended for field devices:
```bash
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Notes
- Desktop platforms skip loading the TFLite model (guarded in `TFLiteService`) so run on Android for inference.
- If camera preview is blank on an emulator, use a physical device; low-end emulators throttle the image stream.
- Keep the model and label files in [assets/models](assets/models); missing assets will disable inference but the app stays usable.
