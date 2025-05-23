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
    apiKey: 'AIzaSyCkbug9ZKC_42vXlS66yphya5Vf3bfk_Z0',
    appId: '1:1076253589553:web:fc5621d745617a029ed510',
    messagingSenderId: '1076253589553',
    projectId: 'uadatingapp',
    authDomain: 'uadatingapp.firebaseapp.com',
    storageBucket: 'uadatingapp.firebasestorage.app',
    measurementId: 'G-SQNV3H1LKD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpG3dUCp-a1qND1VEhKDTaZqEjWuET4b0',
    appId: '1:1076253589553:android:0e77603d31e24aa89ed510',
    messagingSenderId: '1076253589553',
    projectId: 'uadatingapp',
    storageBucket: 'uadatingapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWSYQFwIIMe4Vynmyoze-IukKyJXq65gc',
    appId: '1:1076253589553:ios:4f81c4e2d37faeb39ed510',
    messagingSenderId: '1076253589553',
    projectId: 'uadatingapp',
    storageBucket: 'uadatingapp.firebasestorage.app',
    iosBundleId: 'com.example.uaDatingApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAWSYQFwIIMe4Vynmyoze-IukKyJXq65gc',
    appId: '1:1076253589553:ios:4f81c4e2d37faeb39ed510',
    messagingSenderId: '1076253589553',
    projectId: 'uadatingapp',
    storageBucket: 'uadatingapp.firebasestorage.app',
    iosBundleId: 'com.example.uaDatingApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCkbug9ZKC_42vXlS66yphya5Vf3bfk_Z0',
    appId: '1:1076253589553:web:9146b5f7b51249cb9ed510',
    messagingSenderId: '1076253589553',
    projectId: 'uadatingapp',
    authDomain: 'uadatingapp.firebaseapp.com',
    storageBucket: 'uadatingapp.firebasestorage.app',
    measurementId: 'G-EC8Y91L4CS',
  );
}
