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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDj5sDuqpemidbi8mj5F9NjJz8S6sGllps',
    appId: '1:82399903466:web:da9a7dacabee3eb5882193',
    messagingSenderId: '82399903466',
    projectId: 'communitymanagementsyste-b8d42',
    authDomain: 'communitymanagementsyste-b8d42.firebaseapp.com',
    storageBucket: 'communitymanagementsyste-b8d42.appspot.com',
    measurementId: 'G-G3BGYZSG6C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCM6BRhSxHICQ5P85jJH3XZ19xG8xzzb5g',
    appId: '1:82399903466:android:231595b1d8040c9c882193',
    messagingSenderId: '82399903466',
    projectId: 'communitymanagementsyste-b8d42',
    storageBucket: 'communitymanagementsyste-b8d42.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCbCtc-4RFBCYyJ78r_7OkUeuP5bSXfT_A',
    appId: '1:82399903466:ios:142bc326ad4a3941882193',
    messagingSenderId: '82399903466',
    projectId: 'communitymanagementsyste-b8d42',
    storageBucket: 'communitymanagementsyste-b8d42.appspot.com',
    iosBundleId: 'com.evmak.communitymanagementsystem.communityManagementSystem',
  );

}