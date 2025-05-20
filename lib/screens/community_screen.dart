import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/community/audio_message_widget.dart';
import '../widgets/community/public_profile_popup.dart';


class CommunityScreen  extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _audioPath;
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  @override
  void initState() {
    super.initState();
    _recorder.openRecorder();
    _player.openPlayer();
    _player.onProgress!.listen((event) {
    });
  }

  @override
  void dispose() {
    _player.closePlayer();
    _recorder.closeRecorder();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final userData = await _firestore.collection('users').doc(user.uid).get();
    final username = userData['username'] ?? 'Anónimo';
    final photoUrl = userData['photoUrl'] ?? '';

    await _firestore.collection('community_messages').add({
      'senderId': user.uid,
      'senderUsername': username,
      'photoUrl': photoUrl,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    });

    _messageController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('chat_images/$fileName');
    await ref.putFile(imageFile);
    final imageUrl = await ref.getDownloadURL();

    final user = _auth.currentUser;
    if (user == null) return;

    final userData = await _firestore.collection('users').doc(user.uid).get();
    final username = userData['username'] ?? 'Anónimo';
    final photoUrl = userData['photoUrl'] ?? '';

    await _firestore.collection('community_messages').add({
      'senderId': user.uid,
      'senderUsername': username,
      'photoUrl': photoUrl,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'image',
    });
  }

  Future<void> _startOrStopRecording() async {
    if (!_isRecording) {
      if (await Permission.microphone.request().isGranted) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
        await _recorder.startRecorder(toFile: path);
        setState(() {
          _isRecording = true;
          _audioPath = path;
        });
      }
    } else {
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      if (_audioPath != null) {
        final file = File(_audioPath!);
        final ref = FirebaseStorage.instance
            .ref()
            .child('chat_audios/${DateTime.now().millisecondsSinceEpoch}.aac');
        await ref.putFile(file);
        final audioUrl = await ref.getDownloadURL();

        final user = _auth.currentUser;
        if (user == null) return;

        final userData = await _firestore.collection('users').doc(user.uid).get();
        final username = userData['username'] ?? 'Anónimo';
        final photoUrl = userData['photoUrl'] ?? '';

        await _firestore.collection('community_messages').add({
          'senderId': user.uid,
          'senderUsername': username,
          'photoUrl': photoUrl,
          'audioUrl': audioUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'audio',
        });
      }
    }
  }

  Widget _buildMessageItem(Map<String, dynamic> message, bool isMe) {
    final type = message['type'] ?? 'text';
    final photoUrl = message['photoUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => PublicProfilePopup(userId: message['senderId']),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/profile_images/default.png') as ImageProvider,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF61028D) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message['senderUsername'] ?? 'Usuario',
                    style: TextStyle(
                      fontSize: 20, // Aumentamos tamaño
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (type == 'text') ...[
                    Text(
                      message['message'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ] else if (type == 'image') ...[
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.black,
                            child: InteractiveViewer(
                              child: Image.network(
                                message['imageUrl'],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message['imageUrl'],
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ] else if (type == 'audio') ...[
                    AudioMessageWidget(audioUrl: message['audioUrl'])
                  ],
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/profile_images/default.png') as ImageProvider,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad'),
        backgroundColor: const Color(0xFF61028D),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('community_messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (ctx, index) {
                    final message = docs[index].data() as Map<String, dynamic>;
                    final isMe =
                        message['senderId'] == _auth.currentUser?.uid;
                    return _buildMessageItem(message, isMe);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Color(0xFF61028D)),
                  onPressed: _pickAndSendImage,
                ),
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: const Color.fromARGB(255, 52, 95, 238),
                  ),
                  onPressed: _startOrStopRecording,
                ),
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
                  backgroundColor: const Color(0xFF61028D),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
