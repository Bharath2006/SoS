import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login.dart';

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
  try {
    await Firebase.initializeApp(options: firebaseOptions);
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class SmsSender {
  static const platform = MethodChannel('sms_sender_channel');

  Future<void> sendSms(List<String> contacts, String message) async {
    try {
      await platform.invokeMethod('sendSMS', {
        'phones': contacts,
        'message': message,
      });
    } on PlatformException catch (e) {
      print("Error sending SMS: '${e.message}'.");
    }
  }
}

// Example usage
class MyHomePage extends StatelessWidget {
  final SmsSender smsSender = SmsSender();

  void _sendSms() {
    // Replace with actual phone numbers and message
    List<String> phoneNumbers = ['+919080121722']; // Replace with valid numbers
    String message = 'This is a test message.';

    smsSender.sendSms(phoneNumbers, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMS Sender'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _sendSms,
          child: Text('Send SMS'),
        ),
      ),
    );
  }
}
