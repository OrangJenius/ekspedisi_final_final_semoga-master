import 'package:flutter/material.dart';
import 'package:final_project_semoga/screens/login.dart';
import 'package:http/http.dart' as http;

class LupaPassword2 extends StatefulWidget {
  final String email;

  const LupaPassword2({super.key, required this.email});
  @override
  _LupaPassword2State createState() => _LupaPassword2State();
}

class _LupaPassword2State extends State<LupaPassword2> {
  bool _obscurePassword = true;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  bool _submitNewPassword() {
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;
    if (newPassword == confirmPassword) {
      // TODO: Implement password reset logic here
      print('Password changed successfully!');
      return true;
    } else {
      print('Passwords do not match');
      return false;
    }
  }

  String _message = '';

  Future<void> gantiPass() async {
    setState(() {
      _message = '';
    });
    final apiUrl = 'http://192.168.1.21:1224/forgetPass';
    final password = _newPasswordController.text;
    bool passwordsMatch = _submitNewPassword();
    print(passwordsMatch); // Print the result here
    if (passwordsMatch) {
      print("yoho");
      print(widget.email);
      try {
        final response = await http.put(Uri.parse(apiUrl),
            body: {'email': widget.email, 'password': password});

        if (response.statusCode == 200) {
          // Login successful
          setState(() {
            _message = 'password changed successful';
            _showSuccessSnackbar(
                _message); // Use a custom method for success snackbar
            // Navigate to the HomeScreen if needed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          });
        } else if (response.statusCode == 401) {
          setState(() {
            _message = 'Invalid Password or Confirm password';
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
    } else {
      _message = "password dan confirm password harus sama";
      _showErrorSnackbar(_message);
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green, // Use a success color
      ),
    );
  }

  void _showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ganti Password"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
                controller: _newPasswordController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.black,
                  ),
                  hintText: "New Password",
                ),
                obscureText: _obscurePassword,
              ),
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
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.lock,
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
                  hintText: "Confirm New Password",
                ),
                obscureText: _obscurePassword,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: gantiPass,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                minimumSize: Size(150.0, 50.0),
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
