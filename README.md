# SmartMed - IoT Smart Medicine Reminder and Monitoring System

**SmartMed** is a production-grade IoT mobile application built using **Flutter**, **Firebase**, and **ESP32**. It allows users to schedule medicines, assign them to physical compartments, monitor whether medicines were physically taken via IR sensors, and receive push notifications when a medicine is missed.

---

## 🌟 Key Features
- 🔐 **Firebase Authentication**: Email & Password registration, login, and password reset flows with custom Firestore user documents (`users/{userId}`).
- 📟 **ESP32 Hardware Pairing**: Pair physical smart medicine boxes using unique Device IDs (`devices/{deviceId}`).
- 💊 **Medicine Management & Schedule**: Schedule medicine dosage, quantity, time, instructions, and physical compartment assignment (1..4).
- 📦 **Visual Compartment Box View**: Grid representation of physical compartment boxes 1..4 showing assigned medicines and status.
- 🔔 **5-Minute Timeout & Physical IR Verification**: Status is updated to `taken` **only** when physical IR sensors detect tablet removal. If not removed within 5 minutes, status is automatically set to `missed`.
- 📲 **Firebase Cloud Messaging (FCM)**: Push alerts for missed medicines and device offline alerts.
- 🧪 **Built-in ESP32 Hardware Simulator**: Test IR sensor removal, active reminders, and 5-minute timeout states directly inside the Flutter app without needing physical ESP32 attached.

---

## 🛠️ Technology Stack
- **Mobile Application**: Flutter (Dart)
- **Backend & Database**: Firebase Authentication & Cloud Firestore
- **Push Notifications**: Firebase Cloud Messaging (FCM) & `flutter_local_notifications`
- **Cloud Business Logic**: Firebase Cloud Functions (Node.js)
- **Hardware Layer**: ESP32 with 16x2 LCD I2C, 4x IR Beam Sensors, Piezo Buzzer, and 4x LEDs.

---

## 📂 Project Structure
```text
Smart Medical System/
├── lib/
│   ├── app.dart
│   ├── main.dart
│   ├── data/
│   │   ├── models/           # UserModel, MedicineModel, DeviceModel, MedicineLogModel
│   │   ├── services/         # AuthService, FirestoreService, Esp32Service, MockEsp32HardwareService, NotificationService
│   │   └── repositories/     # AuthRepository, MedicineRepository, DeviceRepository
│   └── ui/
│       ├── core/             # Theme tokens, Custom widgets, CompartmentGridWidget, HardwareSimulatorDialog
│       └── features/         # Splash, Auth, Home/Dashboard, Medicine/Schedule, History, Device, Settings
├── firestore.rules           # Production Firebase Security Rules
├── seed_data.json            # Sample Firestore database state
├── functions/                # Firebase Cloud Functions for FCM missed alerts
│   ├── index.js
│   └── package.json
├── esp32/                    # ESP32 C++ Arduino Firmware
│   └── smartmed_esp32.ino
├── FIREBASE_SETUP.md         # Firebase console & FCM configuration
└── ESP32_SETUP.md            # ESP32 pinout schematic & flashing guide
```

---

## 🚀 Getting Started

### 1. Run Flutter Mobile App:
```bash
flutter pub get
flutter run
```

### 2. Run Built-in ESP32 Simulator:
1. Launch app -> Sign in or Register.
2. Tap the **Developer Board icon 🔌** on Dashboard or navigate to **Settings > ESP32 Hardware Simulator**.
3. Select a medicine and trigger:
   - **Trigger Scheduled Reminder** (Buzzer ON, LED blinking)
   - **IR Sensor: Tablet Removed** (Marks status as TAKEN)
   - **5-Min Timeout Expired** (Marks status as MISSED and triggers FCM alert)
