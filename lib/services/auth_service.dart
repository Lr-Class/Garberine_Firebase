import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrar nuevo usuario
  Future<String?> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required int age,
  }) async {
    try {
      // Validar edad
      if (age <= 0) {
        return 'La edad debe ser mayor que 0.';
      }

      // Crear usuario con correo y contraseña
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Enviar correo de verificación
        await user.sendEmailVerification();

        // Guardar datos adicionales en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'fullName': fullName,
          'age': age,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return null; // éxito
      } else {
        return 'Error al crear usuario.';
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores de autenticación de Firebase
      return e.message ?? 'Error desconocido al registrar el usuario';
    } catch (e) {
      return 'Error desconocido';
    }
  }

  // Iniciar sesión
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        if (user.emailVerified) {
          return null; // éxito
        } else {
          await _auth.signOut();
          return 'Por favor verifica tu correo electrónico antes de iniciar sesión.';
        }
      } else {
        return 'Usuario no encontrado.';
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores de autenticación de Firebase
      return e.message ?? 'Error desconocido al iniciar sesión';
    } catch (e) {
      return 'Error desconocido';
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
