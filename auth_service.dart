// lib/services/auth_service.dart
// All Firebase Auth + user Firestore operations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  // Is anyone logged in right now?
  User? get firebaseUser => _auth.currentUser;

  // REGISTER — creates Auth account + saves profile to Firestore
  Future<UserModel> register({
    required String name,
    required String rollNumber,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final user = UserModel(
        uid: uid,
        name: name.trim(),
        rollNumber: rollNumber.trim(),
        email: email.trim(),
      );
      // Save extra info to Firestore 'users' collection
      await _db.collection('users').doc(uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _errorMessage(e.code);
    }
  }

  // LOGIN — signs in and fetches profile from Firestore
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = _auth.currentUser!.uid;
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) throw 'Account data missing. Contact support.';
      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw _errorMessage(e.code);
    }
  }

  // LOGOUT
  Future<void> logout() => _auth.signOut();

  // Called on app start — checks if user is already logged in
  Future<UserModel?> getCurrentUser() async {
    if (_auth.currentUser == null) return null;
    final doc = await _db
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  // Friendly error messages
  String _errorMessage(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Email already registered. Please login.';
      case 'invalid-email':        return 'Enter a valid email address.';
      case 'weak-password':        return 'Password must be at least 6 characters.';
      case 'user-not-found':       return 'No account found with this email.';
      case 'wrong-password':       return 'Wrong password. Try again.';
      case 'invalid-credential':   return 'Incorrect email or password.';
      case 'too-many-requests':    return 'Too many attempts. Please wait.';
      default:                     return 'Something went wrong. Try again.';
    }
  }
}
