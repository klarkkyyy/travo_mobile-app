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
    apiKey: 'AIzaSyDj7_mHSgU22BfkjEriqADDoNEWwKEgJBM',
    appId: '1:869163675082:web:c10e5b18a5f0615b49f333',
    messagingSenderId: '869163675082',
    projectId: 'travo-app-82341',
    authDomain: 'travo-app-82341.firebaseapp.com',
    storageBucket: 'travo-app-82341.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWsf5DVektv9s9ab2r9mEK92EkLAkwfBY',
    appId: '1:869163675082:android:8f2a3c2364b139d649f333',
    messagingSenderId: '869163675082',
    projectId: 'travo-app-82341',
    storageBucket: 'travo-app-82341.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAHRKL4baN8WoIqYCs5SmwkeWfqrTmoloQ',
    appId: '1:869163675082:ios:91c03f234df03a6649f333',
    messagingSenderId: '869163675082',
    projectId: 'travo-app-82341',
    storageBucket: 'travo-app-82341.firebasestorage.app',
    androidClientId: '869163675082-hc36ksmpv13nk0986sjn8f744br6jd1m.apps.googleusercontent.com',
    iosClientId: '869163675082-7lb9prv9s62fh62vtah173g6b4hdk4j3.apps.googleusercontent.com',
    iosBundleId: 'com.example.travoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAHRKL4baN8WoIqYCs5SmwkeWfqrTmoloQ',
    appId: '1:869163675082:ios:91c03f234df03a6649f333',
    messagingSenderId: '869163675082',
    projectId: 'travo-app-82341',
    storageBucket: 'travo-app-82341.firebasestorage.app',
    androidClientId: '869163675082-hc36ksmpv13nk0986sjn8f744br6jd1m.apps.googleusercontent.com',
    iosClientId: '869163675082-7lb9prv9s62fh62vtah173g6b4hdk4j3.apps.googleusercontent.com',
    iosBundleId: 'com.example.travoApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDj7_mHSgU22BfkjEriqADDoNEWwKEgJBM',
    appId: '1:869163675082:web:c10e5b18a5f0615b49f333',
    messagingSenderId: '869163675082',
    projectId: 'travo-app-82341',
    authDomain: 'travo-app-82341.firebaseapp.com',
    storageBucket: 'travo-app-82341.firebasestorage.app',
  );

}