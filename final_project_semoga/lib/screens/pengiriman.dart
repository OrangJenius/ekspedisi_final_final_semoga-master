import 'dart:async';
import 'dart:convert';

import 'package:final_project_semoga/screens/home.dart';
import 'package:final_project_semoga/screens/laporanKerusakan.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:final_project_semoga/model/pengantaranModel.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  DateTime? now;
  String? formattedDate;
  late SharedPreferences prefs;

  Future<void> initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool('isOnTheWay', true);
    final pengantaranItemJson = json.encode(
        widget.pengantaranItem.toJson()); // Encode pengantaranItem to JSON
    print(widget.pengantaranItem);
    print(pengantaranItemJson);
    prefs.setString('pengantaran_model', pengantaranItemJson);
  }

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
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
    now = DateTime.now();
    formattedDate = DateFormat('yyyy-MM-dd').format(now!);
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
                prefs.remove('isOnTheWay');
                prefs.remove('pengantaran_model');
                postHistory();
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
        "http://116.68.252.201:1224/updateStatus/${widget.pengantaranItem.orderNumber}";
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
        "http://116.68.252.201:1224/Lokasi/${widget.pengantaranItem.kendaraan_id}";
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
      print(formattedDate);
      print(widget.pengantaranItem.orderNumber);
    } else {
      print("Failed to update location. Status code: ${response.statusCode}");
    }
  }

  Future<void> postHistory() async {
    final apiUrl = 'http://116.68.252.201:1224/inputHistory';

    // Persiapkan data yang akan dikirim dalam bentuk JSON

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'ekspedisi_id': widget.pengantaranItem.orderNumber.toString(),
        'tanggal_sampai': formattedDate,
      });
      print(widget.pengantaranItem.orderNumber);
      print(formattedDate);

      if (response.statusCode == 200) {
        print('Data berhasil dikirim');
        print('Response: ${response.body}');
      } else {
        print('Gagal mengirim data. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Errorrrrrrr: $e');
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _stopLocationUpdates(); // Hentikan pemantauan lokasi saat halaman dihancurkan
    super.dispose();
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const int earthRadius = 6371000; // Earth's radius in meters

    final double lat1Rad = startLatitude * (3.141592653589793 / 180);
    final double lon1Rad = startLongitude * (3.141592653589793 / 180);
    final double lat2Rad = endLatitude * (3.141592653589793 / 180);
    final double lon2Rad = endLongitude * (3.141592653589793 / 180);

    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;

    final double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) * math.pow(math.sin(dLon / 2), 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    final double distance = earthRadius * c;
    return distance;
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
                  initializeSharedPreferences();
                  if (_currentLocation != null) {
                    final double distance = calculateDistance(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                      _destLoc.latitude,
                      _destLoc.longitude,
                    );

                    // Define the desired range in meters
                    final double desiredRange =
                        100; // Adjust this value as needed

                    if (distance <= desiredRange) {
                      _showSelesaiDialog();
                    } else {
                      // Show a message or handle the case when the driver is not within range
                      print("Driver belum sampai.");
                    }
                  }
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
