import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Sender',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SmsSenderScreen(),
    );
  }
}

class SmsSenderScreen extends StatefulWidget {
  @override
  _SmsSenderScreenState createState() => _SmsSenderScreenState();
}

class _SmsSenderScreenState extends State<SmsSenderScreen> {
  final TextEditingController _messageController = TextEditingController();
  static const platform = MethodChannel('sms_sender_channel');

  final List<String> contacts = [
    '+91908121722',
    '+919789788225',
    '+919787681001',
  ];

  Future<void> sendSMS(String phone, String message) async {
    try {
      final String result = await platform.invokeMethod('sendSMS', {
        'phone': phone,
        'message': message,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    } catch (e) {
      print("Failed to send SMS: '${e}'.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send SMS')),
      );
    }
  }

  void sendToAllContacts() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      for (String contact in contacts) {
        sendSMS(contact, message);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send SMS to Multiple Contacts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: sendToAllContacts,
              child: Text('Send SMS to All Contacts'),
            ),
          ],
        ),
      ),
    );
  }
}
