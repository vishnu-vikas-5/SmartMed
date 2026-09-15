import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlC0VO2e2sLfi6Vr-vsjMwgo5oYWX4ZZ8',
    appId: '1:119077945924:web:c6d889a56e1c71a5f7b211',
    messagingSenderId: '119077945924',
    projectId: 'samrt-medical-system',
    authDomain: 'samrt-medical-system.firebaseapp.com',
    storageBucket: 'samrt-medical-system.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlC0VO2e2sLfi6Vr-vsjMwgo5oYWX4ZZ8',
    appId: '1:119077945924:android:c6d889a56e1c71a5f7b211',
    messagingSenderId: '119077945924',
    projectId: 'samrt-medical-system',
    storageBucket: 'samrt-medical-system.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlC0VO2e2sLfi6Vr-vsjMwgo5oYWX4ZZ8',
    appId: '1:119077945924:ios:c6d889a56e1c71a5f7b211',
    messagingSenderId: '119077945924',
    projectId: 'samrt-medical-system',
    storageBucket: 'samrt-medical-system.firebasestorage.app',
    iosBundleId: 'smart.med',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDlC0VO2e2sLfi6Vr-vsjMwgo5oYWX4ZZ8',
    appId: '1:119077945924:ios:c6d889a56e1c71a5f7b211',
    messagingSenderId: '119077945924',
    projectId: 'samrt-medical-system',
    storageBucket: 'samrt-medical-system.firebasestorage.app',
    iosBundleId: 'smart.med',
  );
}
