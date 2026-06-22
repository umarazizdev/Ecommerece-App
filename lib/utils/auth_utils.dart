import 'package:firebase_auth/firebase_auth.dart';

class AuthUtils {
  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  static String requireUid() {
    final uid = currentUid;
    if (uid == null || uid.isEmpty) {
      throw Exception('Please login to continue');
    }
    return uid;
  }
}
