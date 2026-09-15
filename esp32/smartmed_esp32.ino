/*
 * SmartMed ESP32 Firmware
 * -----------------------
 * IoT Smart Medicine Reminder & Monitoring Box
 * 
 * Hardware Requirements:
 * - ESP32 Development Board
 * - 16x2 LCD Display with I2C Backpack (Address 0x27)
 * - 4x IR Beam Sensors (Digital Inputs for Compartments 1..4)
 * - 4x LEDs (Compartment Indicators 1..4)
 * - 1x Piezo Buzzer
 * 
 * Communication Architecture:
 * ESP32 <--- Wi-Fi + HTTPS REST API ---> Firebase Firestore <---> Flutter Mobile App
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include <LiquidCrystal_I2C.h>
#include <time.h>

// ---------------------------------------------------------------------------
// CONFIGURATION - UPDATE WITH YOUR NETWORK & FIREBASE CREDENTIALS
// ---------------------------------------------------------------------------
const char* WIFI_SSID     = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

const String FIREBASE_PROJECT_ID = "samrt-medical-system";
const String DEVICE_ID           = "SM-ESP32-001";

// ---------------------------------------------------------------------------
// PIN DEFINITIONS
// ---------------------------------------------------------------------------
const int PIN_BUZZER = 25;

const int PIN_LED_1  = 26;
const int PIN_LED_2  = 27;
const int PIN_LED_3  = 14;
const int PIN_LED_4  = 12;

const int PIN_IR_1   = 34; // Input only pin
const int PIN_IR_2   = 35; // Input only pin
const int PIN_IR_3   = 32;
const int PIN_IR_4   = 33;

// I2C LCD Display (16x2)
LiquidCrystal_I2C lcd(0x27, 16, 2);

// NTP Time Configuration
const char* ntpServer = "pool.ntp.org";
const long  gmtOffset_sec = 19800; // GMT+5:30 (Adjust for your timezone)
const int   daylightOffset_sec = 0;

// ---------------------------------------------------------------------------
// DATA STRUCTURES & GLOBAL STATE
// ---------------------------------------------------------------------------
struct ScheduleItem {
  String medicineId;
  String medicineName;
  String timeStr; // HH:MM
  int compartment;
  int quantity;
  bool enabled;
};

#define MAX_SCHEDULES 10
ScheduleItem schedules[MAX_SCHEDULES];
int scheduleCount = 0;

// Active Reminder Tracking
bool isReminderActive = false;
int activeCompartment = 0;
String activeMedicineId = "";
String activeMedicineName = "";
unsigned long reminderStartTime = 0;
const unsigned long FIVE_MINUTES_MS = 300000; // 5 Minutes = 300,000 ms

unsigned long lastHeartbeatTime = 0;
unsigned long lastScheduleSyncTime = 0;

// ---------------------------------------------------------------------------
// FUNCTION DECLARATIONS
// ---------------------------------------------------------------------------
void connectWiFi();
void syncTime();
void fetchDeviceSchedule();
void sendHeartbeat();
void postFirebaseEvent(String eventType, String medicineId, int compartment);
void triggerReminder(ScheduleItem item);
void checkIRSensorAndTimeout();
void stopReminder();
int getLedPin(int compartment);
int getIrPin(int compartment);

// ---------------------------------------------------------------------------
// SETUP
// ---------------------------------------------------------------------------
void setup() {
  Serial.begin(115200);
  Serial.println("\n[SmartMed ESP32 Firmware Starting...]");

  // Hardware Pin Configuration
  pinMode(PIN_BUZZER, OUTPUT);
  pinMode(PIN_LED_1, OUTPUT);
  pinMode(PIN_LED_2, OUTPUT);
  pinMode(PIN_LED_3, OUTPUT);
  pinMode(PIN_LED_4, OUTPUT);

  pinMode(PIN_IR_1, INPUT);
  pinMode(PIN_IR_2, INPUT);
  pinMode(PIN_IR_3, INPUT);
  pinMode(PIN_IR_4, INPUT);

  // Initialize LCD
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("SmartMed Box 1.0");
  lcd.setCursor(0, 1);
  lcd.print("Connecting Wi-Fi");

  connectWiFi();
  syncTime();

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("SmartMed Box 1.0");
  lcd.setCursor(0, 1);
  lcd.print("Status: Ready");

  fetchDeviceSchedule();
}

// ---------------------------------------------------------------------------
// MAIN LOOP
// ---------------------------------------------------------------------------
void loop() {
  unsigned long currentMillis = millis();

  // Send heartbeat every 60 seconds
  if (currentMillis - lastHeartbeatTime > 60000) {
    lastHeartbeatTime = currentMillis;
    sendHeartbeat();
  }

  // Refresh schedule every 2 minutes
  if (currentMillis - lastScheduleSyncTime > 120000) {
    lastScheduleSyncTime = currentMillis;
    fetchDeviceSchedule();
  }

  // Check if any scheduled medicine time matches current time
  if (!isReminderActive) {
    struct tm timeinfo;
    if (getLocalTime(&timeinfo)) {
      char currentTime[6];
      sprintf(currentTime, "%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min);

      for (int i = 0; i < scheduleCount; i++) {
        if (schedules[i].enabled && schedules[i].timeStr == String(currentTime)) {
          // Trigger reminder if time matches & second == 0
          if (timeinfo.tm_sec == 0) {
            triggerReminder(schedules[i]);
            break;
          }
        }
      }
    }
  }

  // If reminder is currently active, run 5-minute state machine & IR sensor check
  if (isReminderActive) {
    checkIRSensorAndTimeout();
  }

  delay(200);
}

// ---------------------------------------------------------------------------
// REMINDER & SENSOR LOGIC
// ---------------------------------------------------------------------------
void triggerReminder(ScheduleItem item) {
  isReminderActive = true;
  activeCompartment = item.compartment;
  activeMedicineId = item.medicineId;
  activeMedicineName = item.medicineName;
  reminderStartTime = millis();

  Serial.println("[REMINDER STARTED] Medicine: " + activeMedicineName + " | Compartment: " + String(activeCompartment));

  // Display on LCD
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("TAKE MEDICINE!");
  lcd.setCursor(0, 1);
  lcd.print("Box " + String(activeCompartment) + ": " + activeMedicineName);

  // Notify Firebase
  postFirebaseEvent("reminder_started", activeMedicineId, activeCompartment);
}

void checkIRSensorAndTimeout() {
  unsigned long elapsed = millis() - reminderStartTime;
  int ledPin = getLedPin(activeCompartment);
  int irPin = getIrPin(activeCompartment);

  // Blink LED & Pulse Buzzer
  digitalWrite(ledPin, (millis() / 500) % 2);
  if ((millis() / 1000) % 2 == 0) {
    tone(PIN_BUZZER, 2000, 100);
  }

  // Read IR Sensor (HIGH or LOW depending on obstacle sensor configuration)
  // LOW typically means beam broken / medicine removed
  int sensorState = digitalRead(irPin);

  if (sensorState == LOW) {
    Serial.println("[EVENT] IR Sensor detected medicine removed!");
    stopReminder();

    // Display Taken on LCD
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("STATUS: TAKEN!");
    lcd.setCursor(0, 1);
    lcd.print("Thank You!");

    postFirebaseEvent("medicine_taken", activeMedicineId, activeCompartment);
    delay(3000);

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("SmartMed Box 1.0");
    lcd.setCursor(0, 1);
    lcd.print("Status: Ready");
    return;
  }

  // 5-MINUTE TIMEOUT EXPIRED LOGIC
  if (elapsed >= FIVE_MINUTES_MS) {
    Serial.println("[EVENT] 5-minute timeout expired! Medicine MISSED.");
    stopReminder();

    // Display Missed on LCD
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("STATUS: MISSED!");
    lcd.setCursor(0, 1);
    lcd.print("Time Expired");

    postFirebaseEvent("medicine_missed", activeMedicineId, activeCompartment);
    delay(3000);

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("SmartMed Box 1.0");
    lcd.setCursor(0, 1);
    lcd.print("Status: Ready");
  }
}

void stopReminder() {
  isReminderActive = false;
  noTone(PIN_BUZZER);
  digitalWrite(PIN_LED_1, LOW);
  digitalWrite(PIN_LED_2, LOW);
  digitalWrite(PIN_LED_3, LOW);
  digitalWrite(PIN_LED_4, LOW);
}

// ---------------------------------------------------------------------------
// FIREBASE REST API FUNCTIONS
// ---------------------------------------------------------------------------
void fetchDeviceSchedule() {
  if (WiFi.status() != WL_CONNECTED) return;

  WiFiClientSecure client;
  client.setInsecure(); // Disable SSL cert check for ESP32 REST simplicity

  HTTPClient http;
  String url = "https://firestore.googleapis.com/v1/projects/" + FIREBASE_PROJECT_ID + "/databases/(default)/documents/devices/" + DEVICE_ID + "/schedule";

  http.begin(client, url);
  int httpCode = http.GET();

  if (httpCode == HTTP_CODE_OK) {
    String payload = http.getString();
    DynamicJsonDocument doc(4096);
    deserializeJson(doc, payload);

    JsonArray documents = doc["documents"].as<JsonArray>();
    scheduleCount = 0;

    for (JsonObject document : documents) {
      if (scheduleCount >= MAX_SCHEDULES) break;

      JsonObject fields = document["fields"].as<JsonObject>();
      schedules[scheduleCount].medicineId   = fields["medicineId"]["stringValue"].as<String>();
      schedules[scheduleCount].medicineName = fields["medicineName"]["stringValue"].as<String>();
      schedules[scheduleCount].timeStr      = fields["time"]["stringValue"].as<String>();
      schedules[scheduleCount].compartment  = fields["compartment"]["integerValue"].as<int>();
      schedules[scheduleCount].quantity     = fields["quantity"]["integerValue"].as<int>();
      schedules[scheduleCount].enabled      = fields["enabled"]["booleanValue"].as<bool>();
      scheduleCount++;
    }

    Serial.println("[SYNC] Successfully downloaded " + String(scheduleCount) + " schedule items from Firebase.");
  }
  http.end();
}

void postFirebaseEvent(String eventType, String medicineId, int compartment) {
  if (WiFi.status() != WL_CONNECTED) return;

  WiFiClientSecure client;
  client.setInsecure();

  HTTPClient http;
  String url = "https://firestore.googleapis.com/v1/projects/" + FIREBASE_PROJECT_ID + "/databases/(default)/documents/devices/" + DEVICE_ID + "/events";

  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");

  DynamicJsonDocument doc(512);
  JsonObject fields = doc.createNestedObject("fields");

  fields["deviceId"]["stringValue"]    = DEVICE_ID;
  fields["medicineId"]["stringValue"]  = medicineId;
  fields["event"]["stringValue"]       = eventType;
  fields["compartment"]["integerValue"] = compartment;

  String jsonString;
  serializeJson(doc, jsonString);

  int httpCode = http.POST(jsonString);
  Serial.println("[POST EVENT] Code: " + String(httpCode));
  http.end();
}

void sendHeartbeat() {
  if (WiFi.status() != WL_CONNECTED) return;

  WiFiClientSecure client;
  client.setInsecure();

  HTTPClient http;
  String url = "https://firestore.googleapis.com/v1/projects/" + FIREBASE_PROJECT_ID + "/databases/(default)/documents/devices/" + DEVICE_ID + "?updateMask.fieldPaths=status&updateMask.fieldPaths=wifiStatus";

  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");

  DynamicJsonDocument doc(512);
  JsonObject fields = doc.createNestedObject("fields");
  fields["status"]["stringValue"]     = "online";
  fields["wifiStatus"]["stringValue"] = "Connected";

  String jsonString;
  serializeJson(doc, jsonString);

  http.PATCH(jsonString);
  http.end();
}

// ---------------------------------------------------------------------------
// HELPER UTILITIES
// ---------------------------------------------------------------------------
void connectWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n[Wi-Fi Connected] IP: " + WiFi.localIP().toString());
}

void syncTime() {
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  struct tm timeinfo;
  while (!getLocalTime(&timeinfo)) {
    delay(500);
  }
  Serial.println("[NTP Time Synced]");
}

int getLedPin(int compartment) {
  switch (compartment) {
    case 1: return PIN_LED_1;
    case 2: return PIN_LED_2;
    case 3: return PIN_LED_3;
    case 4: return PIN_LED_4;
    default: return PIN_LED_1;
  }
}

int getIrPin(int compartment) {
  switch (compartment) {
    case 1: return PIN_IR_1;
    case 2: return PIN_IR_2;
    case 3: return PIN_IR_3;
    case 4: return PIN_IR_4;
    default: return PIN_IR_1;
  }
}
