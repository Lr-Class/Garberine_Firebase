import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_snackbar.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      final username = userData.exists ? (userData.data()?['username'] ?? 'Anónimo') : 'Anónimo';

      await _firestore.collection('community_messages').add({
        'senderId': user.uid,
        'senderUsername': username,
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'No se pudo enviar el mensaje.',
        backgroundColor: Colors.red, // Color de fondo para error
        textColor: Colors.white, // Color del texto para que sea legible
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('community_messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                reverse: true, // Para que el mensaje más nuevo quede abajo
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final senderUsername = message['senderUsername'] ?? 'Anonimo';
                  final text = message['message'] ?? '';

                  return ListTile(
                    title: Text(senderUsername),
                    subtitle: Text(text),
                  );
                },
              );
            },
          ),
        ),
        Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(hintText: 'Escribe un mensaje...'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
