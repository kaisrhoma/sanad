import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'store_service.dart';

/// Sign-in for institutions only. Young users never sign in.
/// Accounts are created by the Sanad team in Firebase Authentication, and each account
/// needs a matching document in /institutions/{uid} that sets its name and scope.
class PulseAuth {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  /// The signed-in institution, or null.
  static Future<Institution?> current() async {
    final u = _auth.currentUser;
    if (u == null || u.isAnonymous) return null;
    return _load(u.uid);
  }

  static Future<Institution> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    final inst = await _load(cred.user!.uid);
    if (inst == null) {
      await _auth.signOut();
      throw const PulseAuthError('هذا الحساب غير مفعّل كجهة في نبض. تواصل مع فريق سند.');
    }
    return inst;
  }

  static Future<void> signOut() => _auth.signOut();

  static Future<Institution?> _load(String uid) async {
    final d = await _db.collection('institutions').doc(uid).get();
    final data = d.data();
    return data == null ? null : Institution.fromMap(data);
  }

  /// Arabic message for an auth error.
  static String message(Object e) {
    if (e is PulseAuthError) return e.message;
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'invalid-email' => 'صيغة البريد الإلكتروني غير صحيحة.',
        'invalid-credential' || 'wrong-password' || 'user-not-found' => 'البريد أو كلمة المرور غير صحيحة.',
        'user-disabled' => 'هذا الحساب موقوف.',
        'too-many-requests' => 'محاولات كثيرة، حاول بعد قليل.',
        'network-request-failed' => 'لا يوجد اتصال بالإنترنت.',
        _ => 'تعذّر تسجيل الدخول (${e.code}).',
      };
    }
    return 'تعذّر تسجيل الدخول، حاول مرة أخرى.';
  }
}

class PulseAuthError implements Exception {
  final String message;
  const PulseAuthError(this.message);
}
