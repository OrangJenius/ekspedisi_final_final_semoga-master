import 'package:flutter/material.dart';
import 'package:final_project_semoga/screens/login.dart';

class LupaPassword2 extends StatefulWidget {
  @override
  _LupaPassword2 createState() => _LupaPassword2();
}

class _LupaPassword2 extends State<LupaPassword2> {
  bool _obscurePassword = true;
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
