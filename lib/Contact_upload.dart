import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactManagementPage extends StatefulWidget {
  const ContactManagementPage({super.key});

  @override
  _ContactManagementPageState createState() => _ContactManagementPageState();
}

class _ContactManagementPageState extends State<ContactManagementPage>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _contacts = List.filled(5, '');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();
  }

  Future<void> _loadContacts() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        List<dynamic>? savedContacts = data?['contacts'];
        if (savedContacts != null) {
          _contacts = savedContacts.map((e) => e.toString()).toList();
          for (int i = 0; i < _contacts.length; i++) {
            _controllers[i].text = _contacts[i];
          }
          setState(() {});
        }
      }
    }
  }

  Future<void> _saveContacts() async {
    User? user = _auth.currentUser;
    if (user != null) {
      List<String> contactsToSave =
          _controllers.map((controller) => controller.text.trim()).toList();
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'contacts': contactsToSave}, SetOptions(merge: true));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Contacts saved successfully')));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                ...List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: TextField(
                          controller: _controllers[index],
                          decoration: InputDecoration(
                            labelText: 'Contact Number ${index + 1}',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveContacts,
        label: Text('Save Contacts'),
        icon: Icon(Icons.save),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
