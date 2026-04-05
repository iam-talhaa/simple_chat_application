// import 'package:chat/screens/auth_screen.dart';
// import 'package:chat/screens/main_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   FirebaseAuth _auth = FirebaseAuth.instance;

//   final _emailController = TextEditingController();
//   final _passController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login Screen')),
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
//                     .signInWithEmailAndPassword(
//                       email: _emailController.text.toString(),
//                       password: _passController.text.toString(),
//                     )
//                     .then((v) {
//                       print('Login SuccessFull');

//                       Navigator.of(context).push(
//                         MaterialPageRoute(builder: (context) => MainScreen()),
//                       );
//                     })
//                     .onError((error, s) {
//                       print('Error');
//                     });
//               },
//               child: Text("Login "),
//             ),

//             TextButton(
//               onPressed: () {
//                 Navigator.of(
//                   context,
//                 ).push(MaterialPageRoute(builder: (context) => AuthScreen()));
//               },
//               child: Text('SignUp'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
