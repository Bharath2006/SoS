import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:secure_voyage/backtap.dart';
import 'package:secure_voyage/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';

const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyCK4PW3Hns7GxKYe7XfyqBQxCf1G0VtNq4',
  appId: '1:254389889576:web:ad6a07f7196c4963a0631d',
  messagingSenderId: '254389889576',
  projectId: 'women-94051',
  authDomain: 'women-94051.firebaseapp.com',
  storageBucket: 'women-94051.appspot.com',
  measurementId: 'G-ETLFPLTB7G',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? BackTapPage() : SignUpPage(),
    );
  }
}
