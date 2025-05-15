// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/custom_snackbar.dart';
import '../widgets/public_profile_popup.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _animationController;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      final username = userData['username'] ?? 'Anónimo';
      final photoUrl = userData['photoUrl'] ?? '';

      await _firestore.collection('community_messages').add({
        'senderId': user.uid,
        'senderUsername': username,
        'photoUrl': photoUrl,
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'No se pudo enviar el mensaje.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showPublicProfilePopup(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();

    if (data == null) return;

    final username = data['username'] ?? 'Anónimo';
    final name = data['name'] ?? '';
    final rank = data['rank'] ?? 'Sin rango';
    final photoUrl = data['photoUrl'] ?? '';

    showDialog(
      context: context,
      builder: (context) => PublicProfilePopup(
        username: username,
        name: name,
        rank: rank,
        photoUrl: photoUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color colorOriginal = Color.fromARGB(255, 159, 50, 209);
    final currentUser = _auth.currentUser;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Fondo de imagen con opacidad
              Positioned.fill(
                child: Opacity(
                  opacity: 1,
                  child: Image.asset(
                    'assets/images/fondo_community.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('community_messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final senderUsername = message['senderUsername'] ?? 'Anónimo';
                      final text = message['message'] ?? '';
                      final senderId = message['senderId'] ?? '';
                      final photoUrl = message['photoUrl'] ?? '';
                      final timestamp = message['timestamp'] as Timestamp?;
                      final timeString = timestamp != null
                          ? DateFormat('hh:mm a').format(timestamp.toDate())
                          : '';

                      final isMe = currentUser != null && senderId == currentUser.uid;

                      final Animation<double> animation = CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          (1 / messages.length) * index,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      );
                      _animationController.forward();

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    GestureDetector(
                                      onTap: () => _showPublicProfilePopup(senderId),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(photoUrl),
                                        radius: 20,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isMe ? colorOriginal.withOpacity(0.8) : Colors.grey[200],
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                          bottomLeft: isMe ? Radius.circular(15) : Radius.circular(0),
                                          bottomRight: isMe ? Radius.circular(0) : Radius.circular(15),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            senderUsername,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: isMe ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            text,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isMe ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              timeString,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isMe ? Colors.white70 : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 97, 2, 141),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
