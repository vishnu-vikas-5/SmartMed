# SmartMed Firebase Configuration Guide

This guide details how to set up Firebase Authentication, Cloud Firestore, Firebase Cloud Messaging (FCM), and Firebase Cloud Functions for **SmartMed**.

---

## 1. Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project named `SmartMed`.
2. Enable **Firebase Authentication**:
   - Navigation: **Build > Authentication > Sign-in method**
   - Enable **Email/Password** provider.
3. Enable **Cloud Firestore Database**:
   - Navigation: **Build > Firestore Database**
   - Click **Create Database**, select production mode and your preferred cloud region.

---

## 2. Flutter Mobile Application Integration

### Android Setup:
1. Register Android app with package name `com.smartmed.smartmed`.
2. Download `google-services.json` and place it inside:
   ```
   android/app/google-services.json
   ```
3. Ensure `android/build.gradle` includes Google Services classpath:
   ```groovy
   classpath 'com.google.gms:google-services:4.3.15'
   ```

### iOS Setup:
1. Register iOS app with bundle ID `com.smartmed.smartmed`.
2. Download `GoogleService-Info.plist` and place it inside:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

---

## 3. Deploy Firestore Security Rules
Deploy `firestore.rules` using Firebase CLI:
```bash
npx -y firebase-tools deploy --only firestore:rules
```

---

## 4. Deploy Firebase Cloud Functions for FCM Missed Medicine Alerts
1. Navigate to the `functions/` directory:
   ```bash
   cd functions
   npm install
   ```
2. Deploy functions:
   ```bash
   npx -y firebase-tools deploy --only functions
   ```

When an ESP32 posts a `medicine_missed` event to `devices/{deviceId}/events`, the Cloud Function automatically locates the user's FCM tokens and triggers an instant push notification to their mobile device!
