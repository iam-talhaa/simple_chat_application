import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  const ChatScreen({super.key, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  
  String _chatId = '';

  @override
  void initState() {
    super.initState();
    // 5. Create unique chatId using both users
    final currentUserId = _auth.currentUser?.uid ?? '';
    final ids = [currentUserId, widget.receiverId];
    ids.sort(); // Sorting ensures UserA & UserB always get the same ID
    _chatId = ids.join('_');

    
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = _auth.currentUser;

    if (user != null) {
      // 6. Sending Messages to correct chatId
      await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .add({
        'text': text,
        'senderId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 6b. Update the parent document with metadata for previews
      await _firestore.collection('chats').doc(_chatId).set({
        'lastMessage': text,
        'lastTimestamp': FieldValue.serverTimestamp(),
        'users': [user.uid, widget.receiverId],
      }, SetOptions(merge: true));

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // 7. Receiving Messages
              child: StreamBuilder(
                stream: _firestore
                    .collection('chats')
                    .doc(_chatId) // using the unique 1-on-1 ID
                    .collection('messages') // Subcollection for exact messages
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Say hello!'));
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final data = message.data() as Map<String, dynamic>;
                      final text = data['text'] ?? '';
                      final senderId = data['senderId'] ?? '';

                      final isMe = senderId == _auth.currentUser?.uid;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[300] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            text,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Send a message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
