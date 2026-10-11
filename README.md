# 🩺 BP Tracker — Flutter Blood Pressure App

A clean, dark-themed blood pressure tracking app built with Flutter + Riverpod + Hive.

---

## ✨ Features

- **Log readings** — systolic, diastolic, pulse, arm, body position, and custom notes
- **Smart categorization** — auto-classifies readings (Low / Normal / Elevated / Stage 1 / Stage 2 / Crisis) with color coding
- **Dashboard** — hero gauge for latest reading, quick stats, BP reference guide
- **History** — full list with swipe-to-delete, search, and category filtering
- **Trends** — line chart (systolic + diastolic over time), averages, min/max, and category distribution
- **Settings** — data management, BP guidelines reference
- **Offline-first** — all data stored locally with Hive (no internet required)
- **Date/time editing** — log readings with a past timestamp

---

## screenshots



| History Screen | Home Screen | Trends Screen |
|---|---|---|
| ![History](/bp_tracker/screenshots/bpTracker_historyScreen.jpg) | ![Home](/bp_tracker/screenshots/bpTracker_homeScreen.jpg) | ![Trends](/bp_tracker/screenshots/bpTracker_trendsScreen.jpg) |





---

## 🗂 Project Structure

```
lib/
├── main.dart                  # App entry point + Hive init
├── theme/
│   └── app_theme.dart         # Design system (colors, typography, component themes)
├── models/
│   ├── bp_reading.dart        # BpReading model + BpCategory enum
│   └── bp_reading.g.dart      # Hive type adapter (pre-generated)
├── providers/
│   └── bp_provider.dart       # Riverpod providers + BpRepository
├── screens/
│   ├── app_shell.dart         # Bottom nav shell + FAB
│   ├── dashboard_screen.dart  # Home with hero gauge
│   ├── history_screen.dart    # Full reading list
│   ├── trends_screen.dart     # Charts & statistics
│   ├── settings_screen.dart   # Preferences & clear data
│   └── add_reading_sheet.dart # Add/edit modal bottom sheet
├── widgets/
│   └── bp_reading_card.dart   # Reusable reading card + hero gauge widget
└── utils/
    └── bp_utils.dart          # Color helpers, formatters
```

---

## 🚀 Setup

### Prerequisites
- Flutter SDK ≥ 3.0
- Android Studio / VS Code with Flutter extension
- Android device or emulator

### 1. Get dependencies

```bash
flutter pub get
```

### 2. Run on your Samsung device

```bash
# List connected devices
flutter devices

# Run
flutter run
```

### 3. Build release APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `hive_flutter` | Local data persistence |
| `fl_chart` | Line chart for trends |
| `flutter_animate` | Smooth animations |
| `intl` | Date formatting |
| `iconsax` | Icon set |
| `pdf` + `printing` | Future PDF export |
| `path_provider` | File access |

---

## 🎨 Design

- **Background**: `#0D0D0F`
- **Surface**: `#1A1A1F`
- **Accent (Primary)**: `#E8445A` (red)
- **Normal**: `#34C759` (green)
- **Elevated**: `#FF9F0A` (orange)
- **Crisis**: `#FF2D55` (bright red)

---

## 📊 BP Categories (AHA Guidelines)

| Category | Systolic | | Diastolic |
|---|---|---|---|
| Low | < 90 | and | < 60 |
| Normal | < 120 | and | < 80 |
| Elevated | 120–129 | and | < 80 |
| High Stage 1 | 130–139 | or | 80–89 |
| High Stage 2 | ≥ 140 | or | ≥ 90 |
| Crisis | > 180 | or | > 120 |

---

## 🔮 Possible Future Additions

- [ ] PDF export (infrastructure already added)
- [ ] Reminders / notifications
- [ ] Multiple profiles (family members)
- [ ] CSV export
- [ ] iCloud / Google Drive backup
- [ ] Medication tracking
- [ ] Doctor report generation

---

## ⚠️ Disclaimer

This app is for personal tracking only and is **not a medical device**. Always consult a healthcare professional for medical advice.
