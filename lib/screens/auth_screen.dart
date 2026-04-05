import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;

  void _submitAuth() async {
    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // 1. Create a user record in Firestore so other users can see them to chat
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'email': userCredential.user!.email,
              'uid': userCredential.user!.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred.";
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAuth,
              child: Text(_isLogin ? 'Login' : 'Sign Up'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                _isLogin ? 'Create an account' : 'I already have an account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:chat/screens/login_screen.dart';
// import 'package:chat/screens/main_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   FirebaseAuth _auth = FirebaseAuth.instance;

//   final _emailController = TextEditingController();
//   final _passController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('SignUp Screen')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: .center,
//           crossAxisAlignment: .center,
//           children: [
//             TextFormField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.mail),
//                 hintText: 'Enter Your Email',
//               ),
//             ),
//             TextFormField(
//               controller: _passController,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.lock),
//                 hintText: 'Password',
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _auth
//                     .createUserWithEmailAndPassword(
//                       email: _emailController.text.toString(),
//                       password: _passController.text.toString(),
//                     )
//                     .then((v) {
//                       print('Signup SuccessFull');

//                       Navigator.of(context).push(
//                         MaterialPageRoute(builder: (context) => LoginScreen()),
//                       );
//                       final userid = _auth.currentUser!.uid;
//                       FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(userid)
//                           .set({
//                             'Email': _emailController.text.toString(),
//                             'Uid': userid.toString(),
//                             'Created At': FieldValue.serverTimestamp(),
//                           });
//                     })
//                     .onError((error, s) {
//                       print('Error');
//                     });
//               },
//               child: Text("SignUp"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(
//                   context,
//                 ).push(MaterialPageRoute(builder: (context) => LoginScreen()));
//               },
//               child: Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
