# SmartMed ESP32 Hardware & Firmware Guide

This guide explains the hardware schematic, pin assignments, required Arduino IDE libraries, and step-by-step firmware flashing instructions for the SmartMed ESP32 physical medicine box.

---

## Hardware Pinout Diagram

| Hardware Component | ESP32 Pin | Note |
| :--- | :--- | :--- |
| **I2C LCD SDA** | GPIO 21 | LiquidCrystal_I2C |
| **I2C LCD SCL** | GPIO 22 | LiquidCrystal_I2C |
| **Piezo Buzzer** | GPIO 25 | Active Buzzer |
| **LED Compartment 1** | GPIO 26 | Compartment 1 Indicator |
| **LED Compartment 2** | GPIO 27 | Compartment 2 Indicator |
| **LED Compartment 3** | GPIO 14 | Compartment 3 Indicator |
| **LED Compartment 4** | GPIO 12 | Compartment 4 Indicator |
| **IR Sensor 1** | GPIO 34 | Input Only Pin |
| **IR Sensor 2** | GPIO 35 | Input Only Pin |
| **IR Sensor 3** | GPIO 32 | Digital Input |
| **IR Sensor 4** | GPIO 33 | Digital Input |

---

## Required Arduino IDE Libraries
Install the following libraries via **Sketch > Include Library > Manage Libraries**:
1. `ArduinoJson` (v6.21.0 or higher)
2. `LiquidCrystal_I2C` (by Frank de Brabander)
3. `WiFi` & `HTTPClient` (Included in ESP32 Board Core)

---

## Firmware Flashing Instructions

1. Open `esp32/smartmed_esp32.ino` in Arduino IDE.
2. Select Board: **ESP32 Dev Module**.
3. Update Wi-Fi and Firebase configuration variables at top of sketch:
   ```cpp
   const char* WIFI_SSID     = "YOUR_WIFI_SSID";
   const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";
   const String FIREBASE_PROJECT_ID = "YOUR_FIREBASE_PROJECT_ID";
   const String DEVICE_ID           = "SM-ESP32-001";
   ```
4. Connect ESP32 via USB and click **Upload**.
5. Open Serial Monitor at **115200 baud** to view real-time NTP sync, Firebase schedule downloads, and IR sensor event logs.
