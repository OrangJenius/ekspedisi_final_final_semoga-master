import 'package:final_project_semoga/screens/home.dart';
import 'package:final_project_semoga/screens/laporanKerusakan.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Pengiriman extends StatefulWidget {
  final String userID;
  Pengiriman({
    required this.userID,
  });

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

  void _showSelesaiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Selesai"),
          content: Text("Apakah pesanan telah sampai ke tempat tujuan?"),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and navigate back to HomeScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen(
                            userID: widget.userID,
                          )),
                );
              },
              child: Text("Ya"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Tidak"),
            ),
          ],
        );
      },
    );
  }

  Future<void> ambilLokasisekarang() {
    final apiurl = "http://192.168.1.21:1224/kendaraan";
  }

  Future<void> ambilLokasiAwadanTujuanl() {
    final apiurl = "http://192.168.1.21:1224/loginDriver";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracking'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentLocation == null
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
                        infoWindow:
                            const InfoWindow(title: 'Destination Location'),
                      ),
                    },
                    onMapCreated: (GoogleMapController controller) {
                      // Remove the setState call from this method
                      // as it is not required
                    },
                  ),
          ),
          // Add your button here
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceAround, // Align buttons to the left and right
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LaporanKerusakan()));
                },
                child: Text('Kerusakan'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement the right button's functionality here
                  // For example, you can show a dialog, navigate to another screen, etc.
                  _showSelesaiDialog();
                },
                child: Text('Selesai'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
