import 'package:flutter/material.dart';
import 'package:secure_voyage/Contact_upload.dart';
import 'package:secure_voyage/Qr_Code.dart';
import 'package:secure_voyage/location_track.dart';
import 'package:secure_voyage/sound.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

class BackTapPage extends StatefulWidget {
  const BackTapPage({super.key});

  @override
  _BackTapPageState createState() => _BackTapPageState();
}

class _BackTapPageState extends State<BackTapPage> {
  String _locationMessage = 'Waiting for back tap...';
  final double _threshold = 40.0;
  final SOSService _sosService = SOSService();
  final LocationService _locationService = LocationService();
  bool _isTracking = false;
  final SpeechToText _speech = SpeechToText();
  int _helpCommandCount = 0;

  @override
  void initState() {
    super.initState();
    _listenToAccelerometer();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    await _checkAndRequestPermission(
        Permission.location, 'Location permission is required.');
    await _checkAndRequestPermission(
        Permission.microphone, 'Microphone permission is required.');
    _initializeSpeechRecognition();
  }

  Future<void> _checkAndRequestPermission(
      Permission permission, String errorMessage) async {
    var status = await permission.request();
    if (status.isDenied) {
      _showPermissionDeniedSnackBar(errorMessage);
    }
  }

  Future<void> _initializeSpeechRecognition() async {
    bool available = await _speech.initialize();
    if (available) {
      _listenForHelpCommand();
    } else {
      print("Speech recognition not available");
    }
  }

  void _listenForHelpCommand() {
    _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.toLowerCase().contains("help")) {
          _helpCommandCount++;
          if (_helpCommandCount == 2) {
            _triggerSOS();
            _helpCommandCount = 0;
          }
        }
      },
      listenFor: Duration(seconds: 10),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
      onSoundLevelChange: (level) {},
    );
  }

  void _triggerSOS() {
    _sosService.triggerSOSAlert();
    _isTracking = true;
    _locationService.startLocationTracking(context);
    if (_locationService.currentPosition != null) {
      setState(() {
        _locationMessage =
            'Help detected!\nLatitude: ${_locationService.currentPosition!.latitude}\nLongitude: ${_locationService.currentPosition!.longitude}';
      });
      _showFeedbackSnackBar('SOS activated! Location sent.');
      _provideHapticFeedback(); // Provide haptic feedback on SOS activation
    }
  }

  void _listenToAccelerometer() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.z > _threshold) {
        _triggerSOS();
      }
    });
  }

  void _stopTracking() {
    _locationService.stopLocationTracking();
    _sosService.stopSOSAlert();
    _speech.stop();
    setState(() {
      _isTracking = false;
    });
    _showFeedbackSnackBar('Stopped tracking and SOS.');
  }

  void _provideHapticFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500); // Vibrate for 500ms
    }
  }

  void _showFeedbackSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _showPermissionDeniedSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void dispose() {
    _sosService.dispose();
    _locationService.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.contact_phone),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContactManagementPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.lightBlue[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 80),
                  if (_isTracking)
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(Icons.location_on,
                                size: 48, color: Colors.redAccent),
                            SizedBox(height: 10),
                            Text(
                              _locationMessage,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Divider(),
                            SizedBox(height: 10),
                            LocationTracker(locationService: _locationService),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  if (_isTracking)
                    ElevatedButton(
                      onPressed: _stopTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stop, color: Colors.lightBlue[50]),
                          SizedBox(width: 8),
                          Text('Stop Tracking & SOS'),
                        ],
                      ),
                    ),
                  if (!_isTracking)
                    Text(
                      'Double tap to activate',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
