import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  // Seleccionar una imagen desde la galería
  Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Seleccionar una imagen desde la cámara
  Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Subir imagen a Firebase Storage y devolver URL
  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('news_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      await uploadTask;
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }
}
