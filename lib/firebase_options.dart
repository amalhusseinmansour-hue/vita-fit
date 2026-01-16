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
    apiKey: 'AIzaSyCKHjPDVUv1TojwWt69q_VLcVDFmxYrRd8',
    appId: '1:301863850229:android:4f27a2bdd8134fd62935bc',
    messagingSenderId: '301863850229',
    projectId: 'vitafit-471a8',
    storageBucket: 'vitafit-471a8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBP0AluEDvJY2gPwxi8ovF3Ta-ihirinhM',
    appId: '1:301863850229:ios:1b8f17fc8bd5e1cb2935bc',
    messagingSenderId: '301863850229',
    projectId: 'vitafit-471a8',
    storageBucket: 'vitafit-471a8.firebasestorage.app',
    iosBundleId: 'com.vitafitapp.fitness',
  );
}
