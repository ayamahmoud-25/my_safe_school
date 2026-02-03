// File generated manually for iOS/Android Firebase initialization.
// Ensures Firebase works correctly on iOS TestFlight/release builds.

import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isIOS) {
      return ios;
    }
    return android;
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAskYxjOJCS1RO2RmBFdR7_mQxpnXdnlcY',
    appId: '1:645322885560:ios:8ab071da9257e0badea74d',
    messagingSenderId: '645322885560',
    projectId: 'mysafeschool-55e91',
    storageBucket: 'mysafeschool-55e91.firebasestorage.app',
    databaseURL: 'https://mysafeschool-55e91-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBB8ksTQzBkwqg_2luc-Bw36i5nooMGg5U',
    appId: '1:645322885560:android:21cc37330f1439c2dea74d',
    messagingSenderId: '645322885560',
    projectId: 'mysafeschool-55e91',
    storageBucket: 'mysafeschool-55e91.firebasestorage.app',
    databaseURL: 'https://mysafeschool-55e91-default-rtdb.firebaseio.com',
  );
}
