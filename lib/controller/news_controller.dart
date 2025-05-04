import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../services/news_service.dart';
import '../widgets/custom_snackbar.dart';

class NewsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final List<String> allowedEmails = [
    'luismak712@gmail.com',
    'yyafethlopez@unicesar.edu.co',
  ];

  File? image;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  bool isAdmin = false;

  void checkUserRole(VoidCallback refreshUI) {
    User? user = _auth.currentUser;
    if (user != null && allowedEmails.contains(user.email)) {
      isAdmin = true;
      refreshUI();
    }
  }

  Future<void> pickImage(VoidCallback refreshUI) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      refreshUI();
    }
  }

  Future<String> uploadImage() async {
    if (image == null) return '';
    try {
      final ref = _storage.ref().child('news_images').child(DateTime.now().millisecondsSinceEpoch.toString());
      await ref.putFile(image!);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Future<void> submitNews(BuildContext context, VoidCallback clearForm) async {
    User? user = _auth.currentUser;

    if (user == null || !isAdmin) {
      CustomSnackbar.show(
        context: context,
        title: 'Acceso denegado',
        message: 'No tienes permisos para agregar noticias.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (titleController.text.isEmpty || bodyController.text.isEmpty) {
      CustomSnackbar.show(
        context: context,
        title: 'Campos vacíos',
        message: 'Completa todos los campos.',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    String imageUrl = await uploadImage();

    try {
      await NewsService.addNews(
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
        author: user.email!,
        imageUrl: imageUrl,
      );

      CustomSnackbar.show(
        context: context,
        title: '¡Éxito!',
        message: 'Noticia agregada exitosamente.',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      clearForm();
      Navigator.of(context).pop(); // Cerrar modal
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'Error al agregar noticia: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
