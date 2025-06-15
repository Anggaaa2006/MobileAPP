import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar';
        case 'wrong-password':
          return 'Password salah';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'notificationEnabled': true,
          'reminderDays': 3,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Password terlalu lemah';
        case 'email-already-in-use':
          return 'Email sudah terdaftar';
        case 'invalid-email':
          return 'Format email tidak valid';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<String?> updateUserProfile({
    required String fullName,
    required String phone,
    required bool notificationEnabled,
    required int reminderDays,
  }) async {
    if (currentUser == null) return 'User tidak ditemukan';

    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'fullName': fullName,
        'phone': phone,
        'notificationEnabled': notificationEnabled,
        'reminderDays': reminderDays,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}