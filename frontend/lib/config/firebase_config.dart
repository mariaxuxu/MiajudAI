import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBRETjM2GZAom-xBCBfx122xVIqcM4E1Jc',
          appId: '1:920940740455:ios:215da4e4c337612718f9c2',
          messagingSenderId: '920940740455',
          projectId: 'miajudai',
          authDomain: 'miajudai-dev.firebaseapp.com',
          databaseURL: 'miajudai.firebaseapp.com',
          storageBucket: 'miajudai.firebasestorage.app',
        ),
      );
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Firebase initialization error: $e');
    }
  }
}
