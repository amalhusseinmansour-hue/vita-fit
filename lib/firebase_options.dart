/// Firebase Options - Disabled
/// This is a stub file. Firebase will be re-enabled after iOS crash is resolved.

class FirebaseOptions {
  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String? storageBucket;

  const FirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    this.storageBucket,
  });
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Return a dummy object since Firebase is disabled
    return const FirebaseOptions(
      apiKey: '',
      appId: '',
      messagingSenderId: '',
      projectId: '',
    );
  }
}
