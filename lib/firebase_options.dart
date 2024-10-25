// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCAw3Uapngc4IuswkLAhcFgtDlLjpqJVY8',
    appId: '1:498351091702:android:a006743cd2a9c88f67e1d7',
    messagingSenderId: '498351091702',
    projectId: 'madein-a5f78',
    storageBucket: 'madein-a5f78.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBX-OsDNv0-JUsZnNtLua3Mf6ubwXMOBHY',
    appId: '1:498351091702:ios:5f6c5084cb3e58a767e1d7',
    messagingSenderId: '498351091702',
    projectId: 'madein-a5f78',
    storageBucket: 'madein-a5f78.appspot.com',
    iosBundleId: 'com.madein.vendor',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAJ3EwNw_WXwmuB5PgEj6JCh8JxXWvBkoE',
    appId: '1:49459051581:web:86da4bea01e16cd4107e54',
    messagingSenderId: '49459051581',
    projectId: 'icupa-396da',
    authDomain: 'icupa-396da.firebaseapp.com',
    storageBucket: 'icupa-396da.appspot.com',
    measurementId: 'G-D80RPNQVCZ',
  );
}
