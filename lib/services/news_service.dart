import 'package:cloud_firestore/cloud_firestore.dart';

class NewsService {
  static Future<void> addNews({
    required String title,
    required String body,
    required String author,
    required String imageUrl,
  }) async {
    await FirebaseFirestore.instance.collection('news').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'author': author,
      'imageURL': imageUrl,
    });
  }

  static Stream<QuerySnapshot> getNewsStream() {
    return FirebaseFirestore.instance.collection('news')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
