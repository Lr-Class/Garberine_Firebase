import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Actualiza el username y el nombre completo del usuario
  Future<void> updateUsernameAndFullName({required String username, required String fullName}) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado.');

    await _firestore.collection('users').doc(user.uid).update({
      'username': username,
      'fullName': fullName,
    });
  }

  /// Sube una nueva foto de perfil a Firebase Storage y guarda el enlace en Firestore
  Future<String> uploadProfileImage(File imageFile) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado.');

    final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
    await ref.putFile(imageFile);
    final imageUrl = await ref.getDownloadURL();

    // Actualizar el campo de foto en Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'profileImageUrl': imageUrl,
    });

    return imageUrl;
  }

  /// Cambiar la contraseña del usuario
  Future<void> changePassword({required String newPassword}) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado.');

    await user.updatePassword(newPassword);
  }

  /// Eliminar completamente la cuenta del usuario
  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado.');

    // Primero elimina los datos en Firestore
    await _firestore.collection('users').doc(user.uid).delete();

    // Luego elimina su foto de perfil (opcional)
    final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
    try {
      await ref.delete();
    } catch (e) {
      // Si no existe la foto, no pasa nada
    }

    // Finalmente elimina la cuenta de Firebase Auth
    await user.delete();
  }
}
