# KneeVib

> **Screening aid only — not a medical diagnostic tool.**

KneeVib is a Flutter companion app for a low-cost wearable knee monitor
(Smart India Hackathon prototype). It connects to an ESP32-based wearable
over BLE, runs guided recording sessions, downloads data over a local
Wi-Fi hotspot, and computes a prototype roughness score from the vibration
and angle data.

---

## Quick start

### Prerequisites

| Tool | Minimum version |
|---|---|
| Flutter | 3.22.0 |
| Dart | 3.4.0 |
| Android SDK | API 29 (Android 10) |
| iOS SDK | 14.0 |
| Xcode (for iOS) | 15+ |

### 1. Clone and install dependencies

```bash
git clone <repo-url>
cd kneevib
flutter pub get
```

### 2. Generate Drift database code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run in Demo Mode (no hardware needed)

```bash
flutter run
```

Open **Settings** (bottom-nav gear icon) and toggle **Demo Mode** on.
All BLE and Wi-Fi operations are simulated. Two synthetic sessions
(healthy knee and worn knee) are available for download.

---

## Connecting to the real device

### BLE UUIDs

All UUIDs and command strings are in one file:

```
lib/core/ble/ble_constants.dart
```

Every constant is marked `// TODO: match firmware`. Replace with the
actual UUIDs and the device advertised name from your ESP32 firmware.

### Flow

1. **Connect** — tap "Scan for device" on the Device screen.
2. **Calibrate** (optional but recommended) — tap Calibrate and follow
   the 20-second guided routine.
3. **New session** — enter participant ID, select knee side, choose
   duration, tap Start. The screen switches to a countdown (BLE is off
   during recording). The app auto-reconnects and polls for `SAVED`.
4. **Sync** — tap Sync. The app sends the `SYNC` command, displays the
   hotspot SSID/password, then downloads all sessions with progress bars.
   On Android the app binds HTTP requests to the hotspot network
   automatically. On iOS, join the hotspot manually in Wi-Fi settings
   when prompted.
5. **Results** — open Sessions → tap a session to see the score,
   metrics, and L vs R comparison (when both sides exist).

---

## Architecture

```
lib/
├── core/
│   ├── ble/          # BleService interface + RealBleService
│   ├── wifi/         # WifiSyncService interface + RealWifiSyncService
│   ├── db/           # Drift schema (Sessions, SessionFeatures, Participants)
│   ├── config/       # Riverpod providers, demoMode flag
│   ├── router/       # go_router shell + named routes
│   └── theme/        # Light/dark theme, ScoreColors
├── features/
│   ├── onboarding/   # Disclaimer, consent
│   ├── connect/      # BLE scan + status display
│   ├── calibrate/    # CAL command + animated progress
│   ├── session/      # New session + countdown + reconnect
│   ├── sync/         # Hotspot join + download + progress bars
│   ├── sessions/     # Sessions list with score badges
│   ├── result/       # Score gauge + metrics + L-vs-R comparison
│   ├── trends/       # fl_chart line charts
│   ├── export/       # Zip + share_plus + optional upload
│   └── settings/     # Demo mode, about, disclaimer
├── analysis/
│   ├── data_models.dart      # VibRecord, ImuRow, BendSegment, …
│   ├── file_parser.dart      # Binary + CSV + JSON parsers
│   ├── dsp.dart              # Butterworth band-pass, RMS, kurtosis, …
│   ├── bend_segmenter.dart   # Extrema-based bend detection
│   ├── scorer.dart           # Scorer interface + WeightedBaseliner
│   └── analysis_engine.dart  # Isolate-safe pipeline orchestrator
└── mock/
    ├── mock_ble_service.dart       # Simulated BLE state machine
    ├── mock_wifi_sync_service.dart # Simulated hotspot API
    └── mock_data_generator.dart    # Synthetic vib.bin / imu.csv data
```

---

## Scoring

The roughness score (0–10) is computed by `WeightedBaseliner` in
`lib/analysis/scorer.dart`. Weights live in:

```
assets/scoring_config.json
```

Edit the weights and thresholds there without recompiling. The scoring
is hidden behind the `Scorer` interface — swap in a TFLite model later
by implementing the interface.

**The score is labelled "Prototype score" everywhere in the UI.**
It is not validated against clinical outcomes.

---

## Running tests

```bash
flutter test
```

Tests cover:
- `test/analysis/file_parser_test.dart` — binary parser, CSV parser, JSON parser
- `test/analysis/bend_segmenter_test.dart` — bend detection, alignment
- `test/analysis/scorer_test.dart` — score range, monotonicity, config round-trip

---

## Android notes

- `uses-cleartext-traffic="true"` is set because the ESP32 hotspot
  serves plain HTTP on `192.168.4.1`. This does not affect HTTPS.
- On Android 12+, the app uses `WifiNetworkSpecifier` +
  `bindProcessToNetwork` via a platform channel to bind Dio requests
  to the hotspot interface. (Platform channel implementation: TODO)

## iOS notes

- `NEHotspotConfiguration` is attempted first to join the hotspot
  programmatically (requires the **Wireless Accessory Configuration**
  capability in Xcode).
- If that fails, a clear "Join in Settings" instruction card is shown.
- `NSAppTransportSecurity` allows plain HTTP only for `192.168.4.1`.

---

## Privacy

- Anonymous participant IDs only — no names stored anywhere.
- All data stays on the device unless the user explicitly exports or uploads.
- No accounts, no analytics, no ads, no cloud login.
- Export upload is **off by default**.

---

## Disclaimer

KneeVib is a **prototype screening aid**. It does not diagnose medical
conditions and is not a substitute for professional medical advice.
Always consult a qualified healthcare professional.
