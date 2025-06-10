import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_voyage/location_track.dart';

class LocationTracker extends StatefulWidget {
  final LocationService locationService;

  LocationTracker({required this.locationService});

  @override
  State<LocationTracker> createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  @override
  Widget build(BuildContext context) {
    if (widget.locationService.currentPosition != null) {
      final qrData =
          'https://www.google.com/maps/search/?api=1&query=${widget.locationService.currentPosition!.latitude},${widget.locationService.currentPosition!.longitude}';
      return Column(
        children: <Widget>[
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 200.0,
          ),
          SizedBox(height: 20),
          Text('Scan this QR code to view the location!'),
        ],
      );
    } else {
      return Text('No location data available');
    }
  }
}
