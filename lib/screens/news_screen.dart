import 'package:flutter/material.dart';
import '../controller/news_controller.dart';
import '../services/news_service.dart';
import '../widgets/news/news_form_modal.dart';
import '../widgets/news/news_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsController _controller = NewsController();

  @override
  void initState() {
    super.initState();
    _controller.checkUserRole(() => setState(() {}));
  }

  void _openNewsForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewsFormModal(controller: _controller, refreshUI: () => setState(() {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4,
        backgroundColor: const Color.fromARGB(255, 109, 2, 158),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Noticias', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 4),
            Text('Mantente actualizado', style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!_controller.isAdmin)
            Container(
              width: double.infinity,
              color: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Center(
                child: Text(
                  'No tienes permisos para publicar noticias',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder(
              stream: NewsService.getNewsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay noticias disponibles.'));
                }
                final newsList = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: newsList.length,
                  itemBuilder: (context, index) => NewsCard(news: newsList[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _controller.isAdmin
        ? FloatingActionButton.extended(
            onPressed: _openNewsForm,
            backgroundColor: Colors.blueAccent,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Noticia', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        : null,
    );
  }
}
