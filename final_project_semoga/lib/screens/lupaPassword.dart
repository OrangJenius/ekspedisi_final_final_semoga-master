import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:final_project_semoga/screens/lupaPassword2.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:final_project_semoga/model/userModel.dart';

class LupaPassword extends StatefulWidget {
  const LupaPassword({Key? key}) : super(key: key);

  @override
  _LupaPasswordState createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? generatedOtp;

  String generateOtp() {
    // Generate a random 6-digit OTP
    int otp = math.Random().nextInt(999999);
    return otp.toString().padLeft(6, '0'); // Pad with leading zeros if needed
  }

  List<UserModel> userData = [];

  Future<List<UserModel>> cekEmail() async {
    final apiUrl = 'http://116.68.252.201:1224/user';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Successfully fetched data from the API
        // Parse the response body (JSON), which should be a Map<String, dynamic>
        Map<String, dynamic> apiResponse = jsonDecode(response.body);

        //print(apiResponse); // Print the API response to check the data format

        // Assuming that the API response contains a key called 'users' that holds the list of users
        List<dynamic> userList = apiResponse['data'];

        //print(userList);

        // Convert each item in the list to a UserModel instance using the factory method
        List<UserModel> users =
            (userList as List).map((json) => UserModel.fromJson(json)).toList();

        //print(users);

        return users;
      } else {
        // API call failed or returned an error status code
        print('API call failed with status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // Error occurred during API call
      print('Error: $e');
      return [];
    }
  }

  Future<void> sendOtp() async {
    String recipientEmail = _emailController.text;
    generatedOtp = generateOtp(); // Store the generated OTP in a variable

    final smtpServer = gmail('wendyco1234567@gmail.com', 'nazaaelwxchouywv');

    final message = Message()
      ..from = Address('wendyco1234567@gmail.com', 'Company ')
      ..recipients.add(recipientEmail)
      ..subject = 'OTP Verification'
      ..text = 'Your OTP is: $generatedOtp';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error sending OTP email: $e');
    }
  }

  Future<void> checkEmailAndSendOtp() async {
    userData = await cekEmail(); // Fetch user data from the API

    String enteredEmail = _emailController.text;
    String? role;

    //print(userData);

    // Iterate through each UserModel in the userList to find the matching email
    for (var user in userData) {
      if (user.Email == enteredEmail) {
        role = user.Role;
        break; // Exit the loop once a match is found
      }
    }

    if (role != null) {
      if (role.toLowerCase() == "driver") {
        sendOtp(); // Send OTP if the email matches and the role is "driver"
      } else {
        print("Anda bukan driver"); // Otherwise, print the error message
      }
    } else {
      print("Email tidak ditemukan");
    }
  }

  bool verify() {
    String? otpSent = generatedOtp; // Get the OTP sent to the user's email
    String? userOtp = _otpController.text; // Get the user-entered OTP

    // Compare the user-entered OTP with the OTP sent to the user's email
    bool isOtpValid = otpSent == userOtp;

    return isOtpValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ganti Password"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(1, 206, 206, 206),
                        width: 5.0,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.grey,
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.black,
                        ),
                        hintText: "Email",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    width: 8.0), // Add spacing between the input and the button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    minimumSize: Size(100.0, 50.0),
                  ),
                  child: Text('Send OTP'),
                  onPressed: () {
                    checkEmailAndSendOtp();
                  },
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(1, 206, 206, 206),
                  width: 5.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.grey,
              ),
              child: TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.key,
                    color: Colors.black,
                  ),
                  hintText: "OTP",
                ),
              ),
            ),
            SizedBox(height: 8.0),
            SizedBox(height: 24.0),
            FractionallySizedBox(
              widthFactor:
                  0.4, // Menentukan lebar tombol sebagai persentase dari lebar parent
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  // Ubah warna teks tombol menjadi putih
                  minimumSize: Size(50.0, 50.0),
                ),
                child: Text('Submit'),
                onPressed: () {
                  if (verify()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LupaPassword2(
                                email: _emailController.text,
                              )),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
