import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<String?> signUp({
    required String name,
    required String email,
    required String gender,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      await credential.user!.updateDisplayName(name.trim());

      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'gender': gender,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await credential.user!.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e.code);
    } catch (e) {
      print('Sign up error: $e');
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static String _friendlyAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      default:
        return 'Sign up failed. Please try again.';
    }
  }
}