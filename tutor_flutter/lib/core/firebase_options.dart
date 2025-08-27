// Replace with your actual firebase_options via FlutterFire CLI, or fill web config below for web-only tests.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // TEMP web config — replace with values from Firebase Console (App Web)
      return const FirebaseOptions(
        apiKey: 'REPLACE_WITH_WEB_API_KEY',
        authDomain: 'REPLACE_WITH_AUTH_DOMAIN',
        projectId: 'registro-animal-mx',
        storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
        messagingSenderId: 'REPLACE_WITH_SENDER_ID',
        appId: 'REPLACE_WITH_APP_ID',
        measurementId: 'REPLACE_WITH_MEASUREMENT_ID',
      );
    }
    // On mobile/desktop use FlutterFire generated options
    throw UnsupportedError('Use FlutterFire CLI to generate firebase_options.dart for non-web platforms');
  }
}
