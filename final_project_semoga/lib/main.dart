import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project_semoga/screens/home.dart';

void main() {
  runApp(EkspedisiApp());
}

class EkspedisiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          bool isLoggedIn = snapshot.data ?? false;

          SharedPreferences.getInstance().then((prefs) {
            String userID = prefs.getString('userID') ?? '';

            runApp(MaterialApp(
              home: isLoggedIn ? HomeScreen(userID: userID) : Login(),
            ));
          });

          return Container(); // Placeholder widget while initializing
        }
      },
    );
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
