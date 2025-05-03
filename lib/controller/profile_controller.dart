import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>?> loadUserProfile() async {
    if (currentUser == null) return null;

    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile({
    required String username,
    required String fullName,
  }) async {
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser!.uid).update({
      'username': username,
      'fullName': fullName,
    });
  }

  Future<void> updatePassword({
    required String newPassword,
  }) async {
    if (currentUser == null) return;

    await currentUser!.updatePassword(newPassword);
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    if (currentUser == null) return null;

    try {
      final ref = _storage.ref().child('profile_images').child('${currentUser!.uid}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser!.uid).update({
      'photoUrl': imageUrl,
    });
  }

  Future<void> deleteAccount() async {
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser!.uid).delete();
    await currentUser!.delete();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
