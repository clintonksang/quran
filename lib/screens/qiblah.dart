import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quran_app/screens/allsurah_screen.dart';

class CompassScreen extends StatefulWidget {
  @override
  _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  String _direction = 'Calculating...';
  String _distance = 'Calculating...';
  double _bearing = 0.0;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 88, 92, 88),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(pinned: true, delegate: SliverHeaderQibla()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      Transform.rotate(
                        angle: _bearing,
                        child: Image.asset(
                          'assets/images/qibla.png', // Replace with your arrow image asset
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Direction: $_direction\nDistance: $_distance km',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                },
                childCount: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startLocationUpdates() async {
    // Check if location services are enabled
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      // Location services are disabled, ask user to enable them
      print('Location services are disabled. Please enable them.');
      return;
    }

    // Check if location permission is granted
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Location permission is not granted, ask user for permission
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Handle the case where the user denies location permission
        print('Location permission denied');
        return;
      }
    }

    // Start location updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Update every 1 meter
      ),
    ).listen((Position position) {
      _updateCompassDirection(position);
    });
  }

  void _updateCompassDirection(Position position) {
    // Coordinates of the Kaaba in Mecca
    double kaabaLatitude = 21.3891;
    double kaabaLongitude = 39.8579;

    // Calculate the bearing (direction) to the Kaaba
    double bearing = _calculateBearing(
      position.latitude,
      position.longitude,
      kaabaLatitude,
      kaabaLongitude,
    );

    // Calculate the distance to the Kaaba in kilometers
    double distance = _calculateDistance(
      position.latitude,
      position.longitude,
      kaabaLatitude,
      kaabaLongitude,
    );

    // Update the UI with the Mecca direction and distance
    setState(() {
      _direction = '${bearing.toStringAsFixed(2)}°';
      _bearing =
          math.pi / 180 * bearing; // Convert bearing to radians for rotation
      _distance = '${distance.toStringAsFixed(2)}';
    });
  }

  double _calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    double deltaLongitude = endLongitude - startLongitude;
    double x = math.cos(_toRadians(endLatitude)) *
        math.sin(_toRadians(deltaLongitude));
    double y = math.cos(_toRadians(startLatitude)) *
            math.sin(_toRadians(endLatitude)) -
        math.sin(_toRadians(startLatitude)) *
            math.cos(_toRadians(endLatitude)) *
            math.cos(_toRadians(deltaLongitude));
    double bearing = math.atan2(x, y);

    // Convert bearing from radians to degrees
    bearing = _toDegrees(bearing);

    // Normalize the bearing to be in the range [0°, 360°]
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  double _calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadius = 6371.0; // Radius of the Earth in kilometers
    double dLat = _toRadians(endLatitude - startLatitude);
    double dLon = _toRadians(endLongitude - startLongitude);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(startLatitude)) *
            math.cos(_toRadians(endLatitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    double distance = earthRadius * c;
    return distance;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  double _toDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }
}
