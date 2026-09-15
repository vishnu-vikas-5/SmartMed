const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Cloud Function triggered when ESP32 posts a new event into devices/{deviceId}/events
 */
exports.onDeviceEventCreated = functions.firestore
    .document("devices/{deviceId}/events/{eventId}")
    .onCreate(async (snapshot, context) => {
      const eventData = snapshot.data();
      const deviceId = context.params.deviceId;

      if (!eventData || eventData.event !== "medicine_missed") {
        return null;
      }

      console.log(`Medicine missed event logged for device ${deviceId}`);

      // 1. Get device details to find paired userId
      const deviceDoc = await admin.firestore().collection("devices").doc(deviceId).get();
      if (!deviceDoc.exists) return null;

      const userId = deviceDoc.data().userId;
      if (!userId) return null;

      // 2. Fetch user's FCM tokens
      const tokensSnapshot = await admin.firestore()
          .collection("users")
          .doc(userId)
          .collection("fcmTokens")
          .get();

      if (tokensSnapshot.empty) {
        console.log(`No FCM tokens found for user ${userId}`);
        return null;
      }

      const tokens = tokensSnapshot.docs.map((doc) => doc.data().token).filter(Boolean);
      if (tokens.length === 0) return null;

      // 3. Construct Notification Payload
      const compartment = eventData.compartment || 1;
      const payload = {
        notification: {
          title: "⚠ Medicine Missed Alert",
          body: `Medicine in Compartment ${compartment} was not detected as removed within 5 minutes.`,
        },
        data: {
          deviceId: deviceId,
          medicineId: eventData.medicineId || "",
          compartment: String(compartment),
          type: "medicine_missed",
        },
      };

      // 4. Send FCM Push Notification
      const response = await admin.messaging().sendToDevice(tokens, payload);
      console.log("FCM Notification sent successfully:", response.successCount);
      return null;
    });
