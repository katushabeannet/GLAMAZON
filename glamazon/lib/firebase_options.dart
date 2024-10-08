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
    apiKey: 'AIzaSyD1AlTHl26AxJhBuqsQjscHfj3_I5gQuPw',
    appId: '1:191028175058:web:495979601a75a930834d0b',
    messagingSenderId: '191028175058',
    projectId: 'gl-f0936',
    authDomain: 'gl-f0936.firebaseapp.com',
    storageBucket: 'gl-f0936.appspot.com',
    measurementId: 'G-MQJKXY83CF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRUNxWg5EVEerOwTKEyxJFjPh-jiYEW-w',
    appId: '1:191028175058:android:d4277a715ab2a4c3834d0b',
    messagingSenderId: '191028175058',
    projectId: 'gl-f0936',
    storageBucket: 'gl-f0936.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdE9Nx2iGb1wUByTO1_6pnp9wNa5Duhnk',
    appId: '1:191028175058:ios:1c47cfb20bf4546b834d0b',
    messagingSenderId: '191028175058',
    projectId: 'gl-f0936',
    storageBucket: 'gl-f0936.appspot.com',
    iosBundleId: 'com.example.glamazon',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBdE9Nx2iGb1wUByTO1_6pnp9wNa5Duhnk',
    appId: '1:191028175058:ios:1c47cfb20bf4546b834d0b',
    messagingSenderId: '191028175058',
    projectId: 'gl-f0936',
    storageBucket: 'gl-f0936.appspot.com',
    iosBundleId: 'com.example.glamazon',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD1AlTHl26AxJhBuqsQjscHfj3_I5gQuPw',
    appId: '1:191028175058:web:6b63f1cd3ca60126834d0b',
    messagingSenderId: '191028175058',
    projectId: 'gl-f0936',
    authDomain: 'gl-f0936.firebaseapp.com',
    storageBucket: 'gl-f0936.appspot.com',
    measurementId: 'G-4HSNSFDD1H',
  );
}
