import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:final_project_semoga/screens/home.dart';
import 'package:final_project_semoga/screens/laporanKerusakan.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:final_project_semoga/model/pengantaranModel.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:intl/intl.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';

String? globalUserID;
PengantaranModel? globalPengantaranItem;

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(Duration(seconds: 10), (timer) {
    //tempat untuk update lokasi ke rest api ketika berjalan di background
    getLocation();
    print("berjalannnnnnn hahahhahah2");
  });

  print("berjalannnnnnn hahahhahah");
}

Future<void> getLocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String pengantaranItemJson = prefs.getString('pengantaran_model') ?? '';

  // Melakukan decode JSON String ke Map (jika tidak kosong)
  Map<String, dynamic> pengantaranItemMap = {};
  if (pengantaranItemJson.isNotEmpty) {
    pengantaranItemMap = json.decode(pengantaranItemJson);
  }
  PengantaranModel pengantaranItem =
      PengantaranModel.fromJson(pengantaranItemMap);

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation);

  // Position current;
  // Geolocator.getPositionStream().listen((Position newPosition) {
  //   current = newPosition;
  // });

  final apiUrl =
      "http://116.68.252.201:1224/Lokasi/${pengantaranItem.kendaraan_id}";
  final response = await http.put(
    Uri.parse(apiUrl),
    body: {
      "Latitude": position.latitude.toString(),
      "Longitude": position.longitude.toString(),
    },
  );
  if (response.statusCode == 200) {
  } else {}
}

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
  Position? _currentLocation;
  late LatLng _srcLoc;
  late LatLng _destLoc;

  DateTime? now;
  String? formattedDate;
  late SharedPreferences prefs;
  BitmapDescriptor? customMarkerIcon;
  BitmapDescriptor? sourceMarkerIcon;
  BitmapDescriptor? destinationMarkerIcon;

  Timer? _locationTimer;

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
    globalPengantaranItem = widget.pengantaranItem;
    globalUserID = widget.userID;
    initializeService();
    FlutterBackgroundService().invoke("setAsForeground");

    String locawalnospace =
        widget.pengantaranItem.titik_awal.replaceAll(" ", "");
    List<String> LatLngawal = locawalnospace.split(",");
    _srcLoc = LatLng(double.parse(LatLngawal[0]), double.parse(LatLngawal[1]));

    String locAkhirnospace =
        widget.pengantaranItem.titk_akhir.replaceAll(" ", "");
    List<String> LatLngAkhir = locAkhirnospace.split(",");
    _destLoc =
        LatLng(double.parse(LatLngAkhir[0]), double.parse(LatLngAkhir[1]));

    _startLocationUpdates();
    _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentLocation != null) {
        ambilLokasisekarang(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );
      }
    });

    now = DateTime.now();
    formattedDate = DateFormat('yyyy-MM-dd').format(now!);

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1),
      'assets/currentLocation.png', // Replace with your asset path
    ).then((descriptor) {
      setState(() {
        customMarkerIcon = descriptor;
      });
    });

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1),
      'assets/sourceLocation.png', // Replace with your asset path
    ).then((descriptor) {
      setState(() {
        sourceMarkerIcon = descriptor;
      });
    });

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 1),
      'assets/destinationLocation.png', // Replace with your asset path
    ).then((descriptor) {
      setState(() {
        destinationMarkerIcon = descriptor;
      });
    });
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        autoStartOnBoot: true,
        // auto start service
        autoStart: true,
        isForegroundMode: true,

        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );

    service.startService();
  }

  void _startLocationUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle case when location services are disabled
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // Handle case when permission is permanently denied
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Handle case when permission is denied
        return;
      }
    }

    Geolocator.getPositionStream().listen((Position newPosition) {
      setState(() {
        _currentLocation = newPosition;
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
                prefs.remove('isOnTheWay');
                prefs.remove('pengantaran_model');
                postHistory();
                updateStatus();
                _locationTimer?.cancel();
                FlutterBackgroundService().invoke("stopService");
                // _stopLocationUpdates();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      userID: widget.userID,
                    ),
                  ),
                );
              },
              child: Text("Ya"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'ekspedisi_id': widget.pengantaranItem.orderNumber.toString(),
        'tanggal_sampai': formattedDate!,
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

  // @override
  // void dispose() {
  //   FlutterBackgroundService().invoke("setAsBackground");
  //   super.dispose();
  // }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const int earthRadius = 6371000;

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
        //leading: const BackButton(onPressed: null),
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentLocation == null
                ? const Center(child: Text('Fetching location...'))
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentLocation!.latitude,
                        _currentLocation!.longitude,
                      ),
                      zoom: 13.5,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: LatLng(
                          _currentLocation!.latitude,
                          _currentLocation!.longitude,
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
                      ),
                    ),
                  );
                },
                child: Text('Kerusakan'),
              ),
              ElevatedButton(
                onPressed: () {
                  initializeSharedPreferences();
                  if (_currentLocation != null) {
                    final double distance = calculateDistance(
                      _currentLocation!.latitude,
                      _currentLocation!.longitude,
                      _destLoc.latitude,
                      _destLoc.longitude,
                    );

                    final double desiredRange = 100;

                    if (distance <= desiredRange) {
                      _showSelesaiDialog();
                    } else {
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
