// PLACEHOLDER. Running `flutterfire configure` overwrites this file with your
// real project values. Or paste the values from Firebase Console >
// Project settings > Your apps > Web app > SDK setup and configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'Only web is configured. Run `flutterfire configure` for other platforms.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAOZRUZ8UVImJdMiCOi-cGmuODkFw-oSh8',
    appId: '1:420236539845:web:24209bd6434d5d62a83dac',
    messagingSenderId: '420236539845',
    projectId: 'iotapp-a0a6c',
    authDomain: 'iotapp-a0a6c.firebaseapp.com',
    storageBucket: 'iotapp-a0a6c.firebasestorage.app',
  );

}