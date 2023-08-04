import 'package:final_project_semoga/screens/pengiriman.dart';
import 'package:flutter/material.dart';
//import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/pengantaranModel.dart';

class LaporanKerusakan extends StatefulWidget {
  final PengantaranModel pengantaranItem;
  final String userID;

  const LaporanKerusakan({required this.pengantaranItem, required this.userID});

  @override
  _LaporanKerusakanState createState() => _LaporanKerusakanState();
}

class _LaporanKerusakanState extends State<LaporanKerusakan> {
  final TextEditingController _laporanKerusakan = TextEditingController();

  Future<void> postData() async {
    final apiUrl = 'http://192.168.1.21:1224/tambahLaporanKerusakan';

    final laporanKerusakan = _laporanKerusakan.text;
    print(widget.pengantaranItem.kendaraan_id);

    // Persiapkan data yang akan dikirim dalam bentuk JSON

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'kendaraan_id': widget.pengantaranItem.kendaraan_id,
        'laporan_kerusakan': laporanKerusakan
      });

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Pengiriman(
                userID: widget.userID, pengantaranItem: widget.pengantaranItem),
          ),
        );
        print('Data berhasil dikirim');
        print('Response: ${response.body}');
      } else {
        print('Gagal mengirim data. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Laporan Kerusakan"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Deskripsi Kerusakan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                  maxLines: 5,
                  controller: _laporanKerusakan,
                ),
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  postData();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(120.0, 50.0),
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
