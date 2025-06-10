import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  bool isTracking = false;
  Position? currentPosition;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const platform = MethodChannel('sms_sender_channel');

  Future<void> startLocationTracking(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location permissions are denied'),
        ));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Location permissions are permanently denied'),
      ));
      return;
    }

    isTracking = true;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      currentPosition = position;
      _storeOrUpdateLocationInFirebase(position);
    });
  }

  Future<void> _storeOrUpdateLocationInFirebase(Position position) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }
      String mapUrl =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      DocumentSnapshot userDoc = await userDocRef.get();

      List<String>? contacts = List<String>.from(userDoc['contacts'] ?? []);
      String name = userDoc['name'] ?? "Name is missing";

      // Store or update the location in Firestore
      await userDocRef.set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': Timestamp.now(),
        'mapUrl': mapUrl,
      }, SetOptions(merge: true));

      // Send SMS and WhatsApp messages on every location update
      if (contacts.isNotEmpty) {
        await _sendSMSToContacts(contacts, position, mapUrl, name);
        await _sendWhatsAppToContacts(contacts, position, mapUrl, name);
      }
    } catch (e) {
      print("Error storing/updating location in Firebase: $e");
    }
  }

  Future<void> _sendSMSToContacts(List<String> contacts, Position position,
      String mapUrl, String name) async {
    try {
      String message = '$name\n'
          'I need help! My location is:\n'
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}\n'
          'View on map: $mapUrl\n';

      await platform.invokeMethod('sendSMS', {
        'phones': contacts,
        'message': message,
      });
    } catch (e) {
      print("Error sending SMS: $e");
    }
  }

  Future<void> _sendWhatsAppToContacts(List<String> contacts, Position position,
      String mapUrl, String name) async {
    try {
      String message = 'I need help! My location is:\n'
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}\n'
          'View on map: $mapUrl\n';

      await platform.invokeMethod('sendWhatsApp', {
        'phones': contacts,
        'message': message,
      });
    } catch (e) {
      print("Error sending WhatsApp message: $e");
    }
  }

  void stopLocationTracking() {
    if (_positionSubscription != null) {
      _positionSubscription!.cancel();
      isTracking = false;
    }
  }

  void dispose() {
    stopLocationTracking();
  }
}
