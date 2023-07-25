import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:final_project_semoga/screens/home.dart';
import 'package:final_project_semoga/screens/lupaPassword.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  String simpanData = "";

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    final apiUrl =
        'http://10.5.50.150:1224/loginDriver'; // Use HTTPS for secure communication
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(Uri.parse(apiUrl),
          body: {'email': email, 'password': password});

      if (response.statusCode == 200) {
        // Login successful
        final responseData = jsonDecode(response.body);
        final idValue = responseData['id'];
        setState(() {
          _message = 'Login successful';
          if (idValue != null) {
            simpanData = idValue.toString();
          } else {
            simpanData = 'No ID available';
          }
          _showSuccessSnackbar(
              _message); // Use a custom method for success snackbar
          // Navigate to the HomeScreen if needed
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(userID: simpanData)),
          );
        });
      } else if (response.statusCode == 401) {
        // Incorrect login credentials
        setState(() {
          _message = 'Invalid email or password';
          _showErrorSnackbar(_message);
        });
      } else {
        // Other server errors
        setState(() {
          _message = 'Server error occurred. Please try again later.';
          _showErrorSnackbar(_message);
        });
      }
    } catch (e) {
      // Error occurred during API call
      setState(() {
        _message =
            'Failed to connect to the server. Please check your internet connection.';
        _showErrorSnackbar(_message);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green, // Use a success color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 150.0),
              child: Text(
                "Login",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(1, 206, 206, 206),
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.grey),
              child: TextFormField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                    hintText: "Email"),
                controller: _emailController,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(1, 206, 206, 206),
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.grey),
              child: TextFormField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.key,
                      color: Colors.black,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: _togglePasswordVisibility,
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                    ),
                    hintText: "Password"),
                controller: _passwordController,
                obscureText: _obscurePassword,
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // Pindahkan pengguna ke halaman lain di sini
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LupaPassword()),
                  );
                },
                child: Text(
                  "Lupa Password ?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 24.0),
            FractionallySizedBox(
              widthFactor:
                  0.4, // Menentukan lebar tombol sebagai persentase dari lebar parent
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(
                        255, 0, 0, 0), // Ubah warna teks tombol menjadi putih
                    minimumSize: Size(50.0, 50.0)),
                onPressed: _isLoading ? null : _login,
                child: _isLoading ? CircularProgressIndicator() : Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
