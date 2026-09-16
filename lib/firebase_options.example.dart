// Example Firebase config template.
// Copy this file to firebase_options.dart and replace the values with your own Firebase project settings.
// This file is safe to commit because it contains placeholder values only.
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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_WEB_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_YOUR_WEB_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_FIREBASE_PROJECT_ID',
    authDomain: 'REPLACE_WITH_YOUR_PROJECT.firebaseapp.com',
    storageBucket: 'REPLACE_WITH_YOUR_PROJECT.firebasestorage.app',
    measurementId: 'REPLACE_WITH_YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_ANDROID_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_YOUR_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_FIREBASE_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_PROJECT.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_IOS_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_FIREBASE_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_PROJECT.firebasestorage.app',
    androidClientId: 'REPLACE_WITH_YOUR_ANDROID_CLIENT_ID',
    iosClientId: 'REPLACE_WITH_YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.aiStudyNotes',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_IOS_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_FIREBASE_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_PROJECT.firebasestorage.app',
    androidClientId: 'REPLACE_WITH_YOUR_ANDROID_CLIENT_ID',
    iosClientId: 'REPLACE_WITH_YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.aiStudyNotes',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_WEB_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_FIREBASE_PROJECT_ID',
    authDomain: 'REPLACE_WITH_YOUR_PROJECT.firebaseapp.com',
    storageBucket: 'REPLACE_WITH_YOUR_PROJECT.firebasestorage.app',
    measurementId: 'REPLACE_WITH_YOUR_MEASUREMENT_ID',
  );
}
