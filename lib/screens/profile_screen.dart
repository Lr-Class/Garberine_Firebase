import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/profile_controller.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_elevatedbutton.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _profileController = ProfileController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  File? _profileImage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _profileController.loadUserProfile();
    if (userData != null) {
      _usernameController.text = userData['username'] ?? '';
      _fullNameController.text = userData['fullName'] ?? '';
    }
    setState(() {}); 
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);

    if (_profileImage != null) {
      final imageUrl = await _profileController.uploadProfileImage(_profileImage!);
      if (imageUrl != null) {
        await _profileController.updateProfileImage(imageUrl);
      }
    }

    await _profileController.updateUserProfile(
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
    );

    setState(() => _loading = false);

    CustomSnackbar.show(
      context: context,
      title: 'Éxito',
      message: 'Perfil actualizado correctamente.',
      backgroundColor: Colors.green, // Color para éxito
      textColor: Colors.white, // Texto en blanco
    );
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'Las contraseñas no coinciden.',
        backgroundColor: Colors.red, // Color para error
        textColor: Colors.white, // Texto en blanco
      );
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'La contraseña debe tener al menos 6 caracteres.',
        backgroundColor: Colors.red, // Color para error
        textColor: Colors.white, // Texto en blanco
      );
      return;
    }

    try {
      await _profileController.updatePassword(newPassword: _passwordController.text.trim());
      CustomSnackbar.show(
        context: context,
        title: 'Éxito',
        message: 'Contraseña actualizada correctamente.',
        backgroundColor: Colors.green, // Color para éxito
        textColor: Colors.white, // Texto en blanco
      );
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'Error al actualizar contraseña: ${e.toString()}',
        backgroundColor: Colors.red, // Color para error
        textColor: Colors.white, // Texto en blanco
      );
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text('Esta acción eliminará tu cuenta permanentemente.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);
              await _profileController.deleteAccount();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar tu sesión actual?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.blue)),
            onPressed: () async {
              Navigator.pop(context);
              await _profileController.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _usernameController,
              labelText: 'Nombre de usuario',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _fullNameController,
              labelText: 'Nombre completo',
              icon: Icons.badge,
            ),
            const SizedBox(height: 24),
            CustomElevatedButton(
              text: 'Guardar perfil',
              onPressed: _saveProfile,
              isLoading: _loading,
              icon: Icons.save,
            ),
            const Divider(height: 40),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Nueva contraseña',
              obscureText: true,
              icon: Icons.lock,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirmar contraseña',
              obscureText: true,
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 24),
            CustomElevatedButton(
              text: 'Cambiar contraseña',
              onPressed: _changePassword,
              icon: Icons.key,
            ),
            const Divider(height: 40),
            const SizedBox(height: 8),
            CustomElevatedButton(
              text: 'Cerrar sesión',
              onPressed: _confirmSignOut,
              icon: Icons.logout,
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            CustomElevatedButton(
              text: 'Eliminar cuenta',
              onPressed: _confirmDeleteAccount,
              icon: Icons.delete_forever,
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}