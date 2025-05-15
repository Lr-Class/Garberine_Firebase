import 'dart:io';
import 'package:app_garb/widgets/achievements_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controller/profile_controller.dart';
import '../controller/rank_controller.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_elevatedbutton.dart';
import '../widgets/rank_progress_circle.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


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
  String? _photoUrl;
  bool _loading = false;
  String _rank = 'Principiante';
  int _qrScans = 0;
  Map<String, bool> _achievements = {};
  int _maxScansForNextRank = 1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProgressData();
  }

  Future<void> _loadUserData() async {
    final userData = await _profileController.loadUserProfile();
    if (userData != null) {
      _usernameController.text = userData['username'] ?? '';
      _fullNameController.text = userData['fullName'] ?? '';
      _photoUrl = userData['photoUrl'];
    }
    setState(() {}); 
  }

  Future<void> _loadProgressData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _rank = data['rank'] ?? 'Principiante';
        _qrScans = data['qrScans'] ?? 0;
        _achievements = Map<String, bool>.from(data['achievements'] ?? {});
      });

      final currentIndex = rankTiers.indexWhere((r) => r['name'] == _rank);
      final nextIndex = currentIndex + 1;
      setState(() {
        _maxScansForNextRank = nextIndex < rankTiers.length
            ? rankTiers[nextIndex]['minScans'] as int
            : _qrScans;
      });
    }
  }


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _profileImage = imageFile;
        _loading = true;
      });

      try {
        final uploadedUrl = await _profileController.uploadProfileImage(imageFile);
        if (uploadedUrl != null) {
          await _profileController.updateProfileImage(uploadedUrl);
          await _loadUserData();
        }
      } catch (e) {
        print('Error subiendo imagen: $e');
      }

      setState(() {
        _loading = false;
      });
    }
  }


  Future<void> _saveProfile() async {
    setState(() => _loading = true);

    if (_profileImage != null) {
      final imageUrl = await _profileController.uploadProfileImage(_profileImage!);
      if (imageUrl != null) {
        await _profileController.updateProfileImage(imageUrl);
        _photoUrl = imageUrl; // <--- Esta línea es crucial
      }
    }

    await _profileController.updateUserProfile(
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      photoUrl: _photoUrl ?? '',
    );

    setState(() => _loading = false);

    CustomSnackbar.show(
      context: context,
      title: 'Éxito',
      message: 'Perfil actualizado correctamente.',
      backgroundColor: Colors.green,
      textColor: Colors.white,
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

  void _showQRCodePopup(String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tu QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Escanea este código para compartir tu perfil.'),
            const SizedBox(height: 16),
            QrImageView(
              data: userId,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          )
        ],
      ),
    );
  }

  void _showAchievementsPopup() {
    showDialog(
      context: context,
      builder: (_) => AchievementsPopup(achievements: _achievements),
    );
  }

  void _startQRScanner() {
    showDialog(
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) async {
                final barcode = capture.barcodes.first;
                final scannedId = barcode.rawValue;
                if (scannedId == null) return;

                final user = FirebaseAuth.instance.currentUser;
                if (user == null || scannedId == user.uid) {
                  Navigator.pop(context);
                  return;
                }

                final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
                final otherUserDoc = FirebaseFirestore.instance.collection('users').doc(scannedId);

                final userSnapshot = await userDoc.get();
                final data = userSnapshot.data();
                List scannedIds = data?['scannedUserIds'] ?? [];

                if (!scannedIds.contains(scannedId)) {
                  scannedIds.add(scannedId);
                  int newScanCount = (data?['qrScans'] ?? 0) + 1;

                  // Actualizar logros
                  Map<String, bool> updatedAchievements = Map<String, bool>.from(data?['achievements'] ?? {});
                  for (var achievement in achievements) {
                    if (newScanCount >= achievement['requiredScans']) {
                      updatedAchievements[achievement['id']] = true;
                    }
                  }

                  // Actualizar rango
                  String newRank = _rank;
                  for (var tier in rankTiers.reversed) {
                    if (newScanCount >= tier['minScans']) {
                      newRank = tier['name'];
                      break;
                    }
                  }

                  await userDoc.update({
                    'qrScans': newScanCount,
                    'scannedUserIds': scannedIds,
                    'achievements': updatedAchievements,
                    'rank': newRank,
                  });

                  _loadProgressData();

                  final otherUserSnapshot = await otherUserDoc.get();
                  final photoUrl = otherUserSnapshot.data()?['photoUrl'];

                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('¡Escaneo exitoso!'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (photoUrl != null)
                            photoUrl.toString().startsWith('assets/')
                                ? Image.asset(photoUrl, width: 100)
                                : Image.network(photoUrl, width: 100),
                          const SizedBox(height: 8),
                          const Text('¡Has escaneado a un nuevo usuario!'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cerrar'),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  CustomSnackbar.show(
                    context: context,
                    title: 'Escaneo duplicado',
                    message: 'Ya escaneaste este usuario.',
                    backgroundColor: Colors.orange,
                    textColor: Colors.white,
                  );
                }
              },
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 65,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (_photoUrl != null
                        ? (_photoUrl!.startsWith('assets/')
                            ? AssetImage(_photoUrl!) as ImageProvider
                            : NetworkImage(_photoUrl!))
                        : null),
                child: (_profileImage == null && _photoUrl == null)
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            RankProgressCircle(
              qrScans: _qrScans,
              maxScansForNextRank: _maxScansForNextRank,
              currentRank: _rank,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Scan QR code',
                  onPressed: _startQRScanner,
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  tooltip: 'My QR',
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) _showQRCodePopup(user.uid);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_events),
                  tooltip: 'See Achievements',
                  onPressed: _showAchievementsPopup,
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _usernameController,
              labelText: 'Username',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _fullNameController,
              labelText: 'Full Name',
              icon: Icons.badge,
            ),
            const SizedBox(height: 24),
            CustomElevatedButton(
              text: 'Save Profile',
              onPressed: _saveProfile,
              isLoading: _loading,
              icon: Icons.save,
            ),
            const Divider(height: 40),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _passwordController,
              labelText: 'New Password',
              obscureText: true,
              icon: Icons.lock,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              obscureText: true,
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 24),
            CustomElevatedButton(
              text: 'Change Password',
              onPressed: _changePassword,
              icon: Icons.key,
            ),
            const Divider(height: 40),
            const SizedBox(height: 8),
            CustomElevatedButton(
              text: 'Logout',
              onPressed: _confirmSignOut,
              icon: Icons.logout,
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            CustomElevatedButton(
              text: 'Delete Account',
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