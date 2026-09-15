import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with DefaultFirebaseOptions
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase Initialization Note: $e');
  }

  runApp(const SmartMedApp());
}
