import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../widgets/custom_snackbar.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  File? _image;
  bool _isAdmin = false;

  // Correos permitidos
  final List<String> allowedEmails = [
    'luismak712@gmail.com',
    'yyafethlopez@unicesar.edu.co',
  ];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  void _checkUserRole() {
    User? user = _auth.currentUser;
    if (user != null && allowedEmails.contains(user.email)) {
      setState(() => _isAdmin = true);
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _uploadImage() async {
    if (_image == null) return '';

    try {
      final ref = _storage.ref().child('news_images').child(DateTime.now().millisecondsSinceEpoch.toString());
      await ref.putFile(_image!);
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Future<void> _submitNews() async {
    User? user = _auth.currentUser;

    if (user == null || !_isAdmin) {
      CustomSnackbar.show(
        context: context,
        title: 'Acceso denegado',
        message: 'No tienes permisos para agregar noticias.',
        backgroundColor: Colors.red, // Color para error
        textColor: Colors.white, // Texto blanco
      );
      return;
    }

    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      CustomSnackbar.show(
        context: context,
        title: 'Campos vacíos',
        message: 'Completa todos los campos.',
        backgroundColor: Colors.orange, // Color para advertencia
        textColor: Colors.white, // Texto blanco
      );
      return;
    }

    String imageUrl = await _uploadImage();

    try {
      await FirebaseFirestore.instance.collection('news').add({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'author': user.email,
        'imageURL': imageUrl,
      });

      CustomSnackbar.show(
        context: context,
        title: '¡Éxito!',
        message: 'Noticia agregada exitosamente.',
        backgroundColor: Colors.green, // Color para éxito
        textColor: Colors.white, // Texto blanco
      );

      _titleController.clear();
      _bodyController.clear();
      setState(() => _image = null);

    } catch (e) {
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'Error al agregar noticia: $e',
        backgroundColor: Colors.red, // Color para error
        textColor: Colors.white, // Texto blanco
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isAdmin
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(labelText: 'Cuerpo de la noticia'),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Seleccionar Imagen o Cámara'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    if (_image != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Image.file(_image!, height: 200),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitNews,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Agregar Noticia', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Text(
                'No tienes permisos para agregar noticias.',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
    );
  }
}