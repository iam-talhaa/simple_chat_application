import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Direct Messages')),
      body: StreamBuilder(
        // Querying all users from the "users" collection
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          // Filter out the current logged-in user
          final users = snapshot.data!.docs.where((doc) => doc.id != currentUserId).toList();

          if (users.isEmpty) {
            return const Center(child: Text('No other users active.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final String email = userData['email'] ?? 'No Email';
              final String userId = users[index].id;

              // Compute the exact same chatId we used in ChatScreen
              final ids = [currentUserId, userId];
              ids.sort();
              final chatId = ids.join('_');

              // Nested StreamBuilder to fetch the metadata for this specific conversation
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('chats').doc(chatId).snapshots(),
                builder: (context, chatSnapshot) {
                  String lastMsg = 'No messages yet';
                  if (chatSnapshot.hasData && chatSnapshot.data!.exists) {
                    final chatData = chatSnapshot.data!.data() as Map<String, dynamic>;
                    lastMsg = chatData['lastMessage'] ?? 'No messages yet';
                  }

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person), backgroundColor: Colors.blueAccent),
                    title: Text(email),
                    subtitle: Text(
                      lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontStyle: chatSnapshot.hasData && chatSnapshot.data!.exists ? FontStyle.normal : FontStyle.italic,
                        color: chatSnapshot.hasData && chatSnapshot.data!.exists ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to ChatScreen with the selected user's ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(receiverId: userId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
