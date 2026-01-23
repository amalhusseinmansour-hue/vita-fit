import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: 'AIzaSyAYoFJ7YtrxCMYbjJvG3LP29Lv0XRmHLpM',
    appId: '1:100672549900:web:vitafit794a6web',
    messagingSenderId: '100672549900',
    projectId: 'vitafit-794a6',
    storageBucket: 'vitafit-794a6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYoFJ7YtrxCMYbjJvG3LP29Lv0XRmHLpM',
    appId: '1:100672549900:android:4eeec5c9f7a531584baa29',
    messagingSenderId: '100672549900',
    projectId: 'vitafit-794a6',
    storageBucket: 'vitafit-794a6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB39pufVkWCOX3_KCiyAnLXrlBFUTKioes',
    appId: '1:100672549900:ios:10f476529c3ea4814baa29',
    messagingSenderId: '100672549900',
    projectId: 'vitafit-794a6',
    storageBucket: 'vitafit-794a6.firebasestorage.app',
    iosBundleId: 'com.vitafitapp.fitness',
  );
}
