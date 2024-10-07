import 'package:firebase_core/firebase_core.dart';

class FirebaseSetup {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }
}
