import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Pengiriman extends StatefulWidget {
  const Pengiriman({Key? key}) : super(key: key);

  @override
  _PengirimanState createState() => _PengirimanState();
}

class _PengirimanState extends State<Pengiriman> {
  LocationData? _currentLocation;

  static const LatLng _srcLoc = LatLng(37.422131, -122.084801);
  static const LatLng _destLoc = LatLng(37.411374, -122.071204);

  @override
  void initState() {
    super.initState();
    _currentLocation = LocationData.fromMap({
      "latitude": _srcLoc.latitude,
      "longitude": _srcLoc.longitude,
    });
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Handle if location service is not enabled by the user
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // Handle if location permission is not granted by the user
        return;
      }
    }

    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        _currentLocation = newLocation;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<Polyline> _polylines = {};

    if (_currentLocation != null) {
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: [
          _srcLoc,
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          _destLoc
        ],
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracking'),
      ),
      body: _currentLocation == null
          ? const Center(child: Text('Fetching location...'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentLocation!.latitude!,
                  _currentLocation!.longitude!,
                ),
                zoom: 13.5,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!,
                  ),
                  infoWindow: const InfoWindow(title: 'Current Location'),
                ),
                Marker(
                  markerId: const MarkerId('source'),
                  position: _srcLoc,
                  infoWindow: const InfoWindow(title: 'Source Location'),
                ),
                Marker(
                  markerId: const MarkerId('destination'),
                  position: _destLoc,
                  infoWindow: const InfoWindow(title: 'Destination Location'),
                ),
              },
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                // Remove the setState call from this method
                // as it is not required
              },
            ),
    );
  }
}
