import 'dart:convert';
import 'package:final_project_semoga/screens/historyKerusakan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;
  const ProfileScreen({Key? key, required this.userID});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> profileData = {};

  @override
  void initState() {
    super.initState();
    fetchProfile(); // Fetch profile data from API when the screen initializes
  }

  Future<void> fetchProfile() async {
    final apiUrl = 'http://192.168.1.21:1224/profile/${widget.userID}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Successfully fetched data from the API
        // Parse the response body (JSON), which should be a Map<String, dynamic>
        Map<String, dynamic> apiResponse = jsonDecode(response.body);

        setState(() {
          profileData = apiResponse['data']
              [0]; // Store the profile data in the state variable
          print(profileData);
        });
      } else {
        // API call failed or returned an error status code
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Error occurred during API call
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Profile"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            CircleAvatar(
              radius: 80,
              child: Icon(
                Icons.person,
                size: 140,
              ),
            ),
            SizedBox(height: 24),
            Card(
              child: InkWell(
                onTap: () {
                  // Navigate to another page for 'Nama Sopir'
                },
                child: ListTile(
                  title: Text(
                    profileData.isNotEmpty ? profileData['nama'] : 'Loading...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Card(
              child: InkWell(
                onTap: () {
                  // Navigate to another page for 'Alamat'
                },
                child: ListTile(
                  title: Text('Alamat'),
                  subtitle: Text(
                    profileData.isNotEmpty
                        ? profileData['alamat']
                        : 'Loading...',
                  ),
                ),
              ),
            ),
            Card(
              child: InkWell(
                onTap: () {
                  // Navigate to another page for 'No Hp'
                },
                child: ListTile(
                  title: Text('No Hp'),
                  subtitle: Text(
                    profileData.isNotEmpty
                        ? profileData['nomor_telepon'].toString()
                        : 'Loading...',
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HistoryKerusakan()));
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(60.0, 50.0),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Histori Laporan Kerusakan'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Add your desired functionality when the button is pressed
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false, // Pop all routes until the login screen
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(60.0, 50.0),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
