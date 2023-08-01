import 'package:flutter/material.dart';
import 'package:final_project_semoga/screens/lupaPassword2.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math' as math;

class LupaPassword extends StatefulWidget {
  @override
  _LupaPassword createState() => _LupaPassword();
}

class _LupaPassword extends State<LupaPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? generatedOtp;

  String generateOtp() {
    // Generate a random 6-digit OTP
    int otp = math.Random().nextInt(999999);
    return otp.toString().padLeft(6, '0'); // Pad with leading zeros if needed
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
                    sendOtp();
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
                      MaterialPageRoute(builder: (context) => LupaPassword2()),
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
