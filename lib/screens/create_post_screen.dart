import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  final Function()? onPostPublished;
  const CreatePostScreen({super.key, this.onPostPublished});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  void _publishPost() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (title.isEmpty || description.isEmpty) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 1. Create Post Logic
      await FirebaseFirestore.instance.collection('posts').add({
        'title': title,
        'description': description,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _titleController.clear();
        _descController.clear();
        setState(() => _isLoading = false);
        if (widget.onPostPublished != null) {
          widget.onPostPublished!();
        } else {
          Navigator.pop(context); // Fallback if used as a separate page
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                // Publish button
                : ElevatedButton(
                    onPressed: _publishPost,
                    child: const Text('Publish'),
                  ),
          ],
        ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class CreatePostScreen extends StatefulWidget {
//   final Function()? onPostPublished;
//   const CreatePostScreen({super.key, this.onPostPublished});
//   @override
//   State<CreatePostScreen> createState() => _CreatePostScreenState();
// }

// class _CreatePostScreenState extends State<CreatePostScreen> {
//   final firestore = FirebaseFirestore.instance.collection('Posts');
//   final currentUser = FirebaseAuth.instance.currentUser!.uid;

//   final _title = TextEditingController();
//   final _descController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: .center,

//           children: [
//             TextFormField(
//               controller: _title,
//               decoration: InputDecoration(hintText: 'Enter Your Title '),
//             ),
//             SizedBox(height: 20),
//             TextFormField(
//               controller: _descController,
//               decoration: InputDecoration(hintText: 'Description '),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 firestore
//                     .add({
//                       'title': _title.text.toString(),
//                       'description': _descController.text.toString(),
//                       'userId': currentUser.toString(),
//                       'timestamp': FieldValue.serverTimestamp(),
//                     })
//                     .then((onValue) {
//                       _title.clear();
//                       _descController.clear();

//                       print('Data Added Successfully');
//                     })
//                     .onError((handleError, v) {
//                       print('ERROR OCCUR');
//                     });
//               },
//               child: Text('Add Post'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
