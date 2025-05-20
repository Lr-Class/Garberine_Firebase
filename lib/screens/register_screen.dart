import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../widgets/general/custom_elevatedbutton.dart';
import '../widgets/general/custom_snackbar.dart';
import '../widgets/general/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _loading = false;
  int _currentAvatarIndex = 0;
  File? _selectedImage;

  final List<String> _avatarPaths = [
    'assets/profile_images/avatar1.png',
    'assets/profile_images/avatar2.png',
    'assets/profile_images/avatar3.png',
    'assets/profile_images/avatar4.png',
    'assets/profile_images/avatar5.png',
  ];

  void _nextAvatar() {
    setState(() {
      if (_currentAvatarIndex < _avatarPaths.length - 1) {
        _currentAvatarIndex++;
      } else {
        _currentAvatarIndex = 0;
      }
      _selectedImage = null;
    });
  }

  void _previousAvatar() {
    setState(() {
      if (_currentAvatarIndex > 0) {
        _currentAvatarIndex--;
      } else {
        _currentAvatarIndex = _avatarPaths.length - 1;
      }
      _selectedImage = null;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _openImagePickerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Seleccionar imagen"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galería"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Cámara"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final String? errorMessage = await AuthService().register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      localImageFile: _selectedImage,
      defaultAvatarPath: _selectedImage == null ? _avatarPaths[_currentAvatarIndex] : null,
    );

    setState(() => _loading = false);

    if (errorMessage != null) {
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: errorMessage,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      CustomSnackbar.show(
        context: context,
        title: '¡Éxito!',
        message: 'Registro exitoso. Verifica tu correo electrónico.',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _selectedImage != null
        ? FileImage(_selectedImage!)
        : AssetImage(_avatarPaths[_currentAvatarIndex]) as ImageProvider;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: avatar,
                    ),
                    Positioned(
                      left: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: _previousAvatar,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: _nextAvatar,
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo, color: Colors.blue),
                        onPressed: _openImagePickerDialog,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _usernameController,
                labelText: 'Nombre de usuario (Juego)',
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _fullNameController,
                labelText: 'Nombre real',
                icon: Icons.abc,
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _ageController,
                labelText: 'Edad',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obligatorio';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Correo electrónico',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Contraseña',
                obscureText: true,
                icon: Icons.lock,
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                text: 'Registrarse',
                onPressed: _register,
                isLoading: _loading,
                backgroundColor: Colors.blueAccent,
                icon: Icons.person_add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
