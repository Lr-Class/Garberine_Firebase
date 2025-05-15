import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> register({
  required String email,
  required String password,
  required String username,
  required String fullName,
  required int age,
  File? localImageFile,
  String? defaultAvatarPath,
}) async {
  try {
    if (age <= 0) {
      return 'La edad debe ser mayor que 0.';
    }

    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(email: email, password: password);

    final User? user = userCredential.user;
    if (user == null) return 'Error al crear usuario.';

    await user.sendEmailVerification();

    String? photoUrl;

    if (localImageFile != null) {
      final String imageId = const Uuid().v4();
      final ref = _storage.ref().child('profile_images/$imageId.jpg');
      await ref.putFile(localImageFile);
      photoUrl = await ref.getDownloadURL();
    } else if (defaultAvatarPath != null) {
      photoUrl = defaultAvatarPath;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'username': username,
      'fullName': fullName,
      'age': age,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'reactionTimeScore': 0,
      'simonSaysScore': 0,
      'tappingGameScore': 0,
      'qrScans': 0,
      'scannedUserIds': [],
      'rank': 'Principiante',
      'achievements': {
        'firstScan': false,
        'fiveScans': false,
        'tenScans': false,
        'twentyScans': false,
      },
    });

    return null;
  } on FirebaseAuthException catch (e) {
    return e.message ?? 'Error desconocido al registrar el usuario';
  } catch (e) {
    return 'Error desconocido';
  }
}

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user == null) return 'Usuario no encontrado.';
      if (!user.emailVerified) {
        await _auth.signOut();
        return 'Por favor verifica tu correo electrónico antes de iniciar sesión.';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Error desconocido al iniciar sesión';
    } catch (e) {
      return 'Error desconocido';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
