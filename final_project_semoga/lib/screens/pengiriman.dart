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
  final String kendaraan_id;
  final PengantaranModel pengantaranItem;
  Pengiriman({
    required this.userID,
    required this.kendaraan_id,
    required this.pengantaranItem,
  });

  @override
  _PengirimanState createState() => _PengirimanState();
}

class _PengirimanState extends State<Pengiriman> {
  LocationData? _currentLocation;
  late LatLng _srcLoc;
  late LatLng _destLoc;

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
    _getCurrentLocation();
    Timer.periodic(Duration(minutes: 1), (timer) {
      if (_currentLocation != null) {
        ambilLokasisekarang(
            _currentLocation!.latitude!, _currentLocation!.longitude!);
      }
    });
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

  Future<void> ambilLokasisekarang(double latitude, double longitude) async {
    final apiUrl = "http://192.168.1.21:1224/lokasi/${widget.userID}";
    final response = await http.put(
      Uri.parse(apiUrl),
      body: {
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
      },
    );

    if (response.statusCode == 200) {
      print("Location updated successfully!");
    } else {
      print("Failed to update location. Status code: ${response.statusCode}");
    }
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
                          builder: (context) => LaporanKerusakan(
                                kendaraan_id: widget.kendaraan_id,
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
