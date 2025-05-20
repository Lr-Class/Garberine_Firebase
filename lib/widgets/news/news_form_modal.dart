import 'package:flutter/material.dart';
import '../../controller/news_controller.dart';

class NewsFormModal extends StatelessWidget {
  final NewsController controller;
  final VoidCallback refreshUI;

  const NewsFormModal({Key? key, required this.controller, required this.refreshUI}) : super(key: key);

  void clearForm() {
    controller.titleController.clear();
    controller.bodyController.clear();
    controller.image = null;
    refreshUI();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Crear Nueva Noticia',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 20),
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.bodyController,
              decoration: InputDecoration(
                labelText: 'Contenido de la noticia',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.pickImage(refreshUI),
              icon: const Icon(Icons.image_outlined),
              label: const Text('Seleccionar Imagen'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            if (controller.image != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(controller.image!, height: 200, fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.submitNews(context, clearForm),
              child: const Text('Publicar Noticia', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
