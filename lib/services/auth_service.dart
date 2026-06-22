import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> cacheUserData({
    required String uid,
    required String name,
    required String email,
    bool isAdmin = false,
  }) async {
    await box.write('uid', uid);
    await box.write('name', name);
    await box.write('email', email);
    await box.write('isAdmin', isAdmin);
  }

  bool parseAdminField(Map<String, dynamic> data) {
    if (!data.containsKey('admin')) return false;
    final admin = data['admin'];
    if (admin is bool) return admin;
    if (admin is String) {
      return admin.toLowerCase() == 'true' || admin.toLowerCase() == 'admin';
    }
    return false;
  }

  bool get isAdminUser => box.read('isAdmin') == true;

  Future<void> _cacheFromAuthUser(User user) async {
    await cacheUserData(
      uid: user.uid,
      name: user.displayName ?? box.read('name')?.toString() ?? '',
      email: user.email ?? '',
      isAdmin: box.read('isAdmin') == true,
    );
  }

  Future<void> loadUserFromFirestore(String uid) async {
    try {
      final doc = await FirebasePaths.userDoc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        await cacheUserData(
          uid: uid,
          name: data['name']?.toString() ?? '',
          email: data['email']?.toString() ?? '',
          isAdmin: parseAdminField(data),
        );
        return;
      }

      await cacheUserData(
        uid: uid,
        name: box.read('name')?.toString() ?? '',
        email: box.read('email')?.toString() ?? '',
        isAdmin: false,
      );
    } catch (_) {
      // Fall back to Firebase Auth profile data.
    }

    final user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      await _cacheFromAuthUser(user);
    }
  }

  Future<void> _saveUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await FirebasePaths.userDoc(uid).set({
        'name': name,
        'email': email,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Profile is still cached locally; Firestore sync can retry later.
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      await loadUserFromFirestore(user.uid);
    }

    return credential;
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      final trimmedName = name.trim();
      final trimmedEmail = email.trim();

      await _saveUserProfile(
        uid: user.uid,
        name: trimmedName,
        email: trimmedEmail,
      );

      await cacheUserData(
        uid: user.uid,
        name: trimmedName,
        email: trimmedEmail,
        isAdmin: false,
      );
    }

    return credential;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> updateProfile({required String name}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final trimmedName = name.trim();
    try {
      await FirebasePaths.userDoc(user.uid).set(
        {'name': trimmedName},
        SetOptions(merge: true),
      );
    } catch (_) {
      EasyLoading.showToast(
        'Saved locally. Deploy Firestore rules to sync profile.',
      );
    }

    await cacheUserData(
      uid: user.uid,
      name: trimmedName,
      email: user.email ?? box.read('email')?.toString() ?? '',
      isAdmin: isAdminUser,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await box.remove('uid');
    await box.remove('name');
    await box.remove('email');
    await box.remove('isAdmin');
  }

  String authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  Future<T> runWithLoading<T>(Future<T> Function() action) async {
    EasyLoading.show();
    try {
      return await action();
    } finally {
      EasyLoading.dismiss();
    }
  }
}
