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
    apiKey: 'AIzaSyDHPz5iej1JWxr7i59y0YyFb-NTK3ievcg',
    appId: '1:889972463280:web:33478a4f4d8d928cfc8d75',
    messagingSenderId: '889972463280',
    projectId: 'live-stock-management-6a11a',
    authDomain: 'live-stock-management-6a11a.firebaseapp.com',
    storageBucket: 'live-stock-management-6a11a.firebasestorage.app',
    measurementId: 'G-T0XVCWQ57E',
      databaseURL: 'https://live-stock-management-6a11a-default-rtdb.asia-southeast1.firebasedatabase.app/'
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGuzC4IE_TuN4wXM9QolbLzBBfpzyAx6U',
    appId: '1:889972463280:android:9be2d38d70fbb49bfc8d75',
    messagingSenderId: '889972463280',
    projectId: 'live-stock-management-6a11a',
    storageBucket: 'live-stock-management-6a11a.firebasestorage.app',
    databaseURL: 'https://live-stock-management-6a11a-default-rtdb.asia-southeast1.firebasedatabase.app/'
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCx45lXMe6z5hEc-VRUAR-PbDDwbnUzA_4',
    appId: '1:889972463280:ios:c26560795d8786edfc8d75',
    messagingSenderId: '889972463280',
    projectId: 'live-stock-management-6a11a',
    storageBucket: 'live-stock-management-6a11a.firebasestorage.app',
    iosBundleId: 'com.example.livestockmanagement',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCx45lXMe6z5hEc-VRUAR-PbDDwbnUzA_4',
    appId: '1:889972463280:ios:c26560795d8786edfc8d75',
    messagingSenderId: '889972463280',
    projectId: 'live-stock-management-6a11a',
    storageBucket: 'live-stock-management-6a11a.firebasestorage.app',
    iosBundleId: 'com.example.livestockmanagement',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDHPz5iej1JWxr7i59y0YyFb-NTK3ievcg',
    appId: '1:889972463280:web:12d0217d0a27a94efc8d75',
    messagingSenderId: '889972463280',
    projectId: 'live-stock-management-6a11a',
    authDomain: 'live-stock-management-6a11a.firebaseapp.com',
    storageBucket: 'live-stock-management-6a11a.firebasestorage.app',
    measurementId: 'G-6Z8LQDZKT0',
  );
}
