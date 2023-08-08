import 'dart:async';

import 'package:final_project_semoga/screens/home.dart';
import 'package:final_project_semoga/screens/laporanKerusakan.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:final_project_semoga/model/pengantaranModel.dart';
import 'package:http/http.dart' as http;

class Pengiriman extends StatefulWidget {
  final String userID;
  final PengantaranModel pengantaranItem;
  Pengiriman({
    required this.userID,
    required this.pengantaranItem,
  });

  @override
  _PengirimanState createState() => _PengirimanState();
}

class _PengirimanState extends State<Pengiriman> {
  LocationData? _currentLocation;
  late LatLng _srcLoc;
  late LatLng _destLoc;
  late Location location;

  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    String locawalnospace =
        widget.pengantaranItem.titik_awal.replaceAll(" ", "");
    List<String> LatLngawal = locawalnospace.split(",");
    _srcLoc = LatLng(double.parse(LatLngawal[0]), double.parse(LatLngawal[1]));

    String locAkhirnospace =
        widget.pengantaranItem.titk_akhir.replaceAll(" ", "");
    List<String> LatLngAkhir = locAkhirnospace.split(",");
    _destLoc =
        LatLng(double.parse(LatLngAkhir[0]), double.parse(LatLngAkhir[1]));

    _currentLocation = LocationData.fromMap({
      "latitude": _srcLoc.latitude,
      "longitude": _srcLoc.longitude,
    });
    _startLocationUpdates();
    _locationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_currentLocation != null) {
        ambilLokasisekarang(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        );
      }
    });
  }

  StreamSubscription<LocationData>? _locationSubscription;

  void _startLocationUpdates() async {
    location = Location();
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

    _locationSubscription =
        location.onLocationChanged.listen((LocationData newLocation) {
      if (mounted) {
        setState(() {
          _currentLocation = newLocation;
        });
      }
    });
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
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
                updateStatus();
                dispose();
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

  Future<void> updateStatus() async {
    final apiurl =
        "http://192.168.1.21:1224/updateStatus/${widget.pengantaranItem.orderNumber}";
    final response =
        await http.put(Uri.parse(apiurl), body: {"status": "selesai"});

    if (response.statusCode == 200) {
      print("Status updated successfully!");
    } else {
      print("Failed to update status. Status code: ${response.statusCode}");
    }
  }

  Future<void> ambilLokasisekarang(double latitude, double longitude) async {
    final apiUrl =
        "http://192.168.1.21:1224/Lokasi/${widget.pengantaranItem.kendaraan_id}";
    final response = await http.put(
      Uri.parse(apiUrl),
      body: {
        "Latitude": latitude.toString(),
        "Longitude": longitude.toString(),
      },
    );

    if (response.statusCode == 200) {
      print("Location updated successfully!");
      print(latitude.toString());
      print(longitude.toString());
    } else {
      print("Failed to update location. Status code: ${response.statusCode}");
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _stopLocationUpdates(); // Hentikan pemantauan lokasi saat halaman dihancurkan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracking'),
        automaticallyImplyLeading: false,
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
                          builder: (context) => LaporanKerusakan(
                                pengantaranItem: widget.pengantaranItem,
                                userID: widget.userID,
                              )));
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
