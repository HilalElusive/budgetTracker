// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCQMRkuU3IpLE-Uno1tHnnPUAc-XiR_c_E',
    appId: '1:191996993094:web:5410d56f8ca4974c2eb447',
    messagingSenderId: '191996993094',
    projectId: 'budget-tracker-a471a',
    authDomain: 'budget-tracker-a471a.firebaseapp.com',
    storageBucket: 'budget-tracker-a471a.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAEKSmqixKA1wBgutox_uRKd_ODnFefKyE',
    appId: '1:191996993094:android:9b1dff848b3ec8802eb447',
    messagingSenderId: '191996993094',
    projectId: 'budget-tracker-a471a',
    storageBucket: 'budget-tracker-a471a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDFUOtqMd953enzuY92s72SpjnyApdcw54',
    appId: '1:191996993094:ios:721d5ec65db9c9652eb447',
    messagingSenderId: '191996993094',
    projectId: 'budget-tracker-a471a',
    storageBucket: 'budget-tracker-a471a.appspot.com',
    iosClientId: '191996993094-rkasvjk4f7m1pqbfhf900hlupsq3qmo9.apps.googleusercontent.com',
    iosBundleId: 'com.example.budgettracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDFUOtqMd953enzuY92s72SpjnyApdcw54',
    appId: '1:191996993094:ios:721d5ec65db9c9652eb447',
    messagingSenderId: '191996993094',
    projectId: 'budget-tracker-a471a',
    storageBucket: 'budget-tracker-a471a.appspot.com',
    iosClientId: '191996993094-rkasvjk4f7m1pqbfhf900hlupsq3qmo9.apps.googleusercontent.com',
    iosBundleId: 'com.example.budgettracker',
  );
}
