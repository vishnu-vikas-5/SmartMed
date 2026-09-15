import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Request FCM permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Setup Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click
      },
    );

    // 3. Listen to foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'SmartMed Alert',
          body: message.notification!.body ?? '',
        );
      }
    });

    _initialized = true;
  }

  /// Save FCM token securely under users/{userId}/fcmTokens/{tokenId}
  Future<void> saveTokenToFirestore(String userId) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('fcmTokens')
            .doc(token)
            .set({
          'token': token,
          'createdAt': FieldValue.serverTimestamp(),
          'platform': 'flutter',
        });
      }
    } catch (_) {}
  }

  /// Show a local notification dialog/banner
  Future<void> showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'smartmed_channel',
      'SmartMed Notifications',
      channelDescription: 'Alerts for medicine reminders, missed doses, and device status',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      id,
      title,
      body,
      platformDetails,
    );
  }

  /// Show specific Missed Medicine Notification
  Future<void> showMedicineMissedNotification({
    required String medicineName,
    required String time,
  }) async {
    await showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '⚠ Medicine Missed',
      body: '$medicineName scheduled for $time was not detected.',
    );
  }

  /// Show Device Offline Notification
  Future<void> showDeviceOfflineNotification(String deviceName) async {
    await showLocalNotification(
      id: 999,
      title: '$deviceName Offline',
      body: 'Your SmartMed medicine box has not connected to the server recently.',
    );
  }
}
