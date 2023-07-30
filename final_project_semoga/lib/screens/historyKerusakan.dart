import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/historyKerusakan.dart';

class HistoryKerusakan extends StatefulWidget {
  @override
  _HistoryKerusakan createState() => _HistoryKerusakan();
}

class _HistoryKerusakan extends State<HistoryKerusakan> {
  List<ModelHistoryKerusakan> historyKerusakan = [];

  @override
  void initState() {
    super.initState();
    fetchHistoryKerusakan();
  }

  Future<void> fetchHistoryKerusakan() async {
    final apiUrl = 'http://192.168.1.21:1224/laporanKerusakan';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> apiHistoryData =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        List<ModelHistoryKerusakan> test = apiHistoryData
            .map((data) => ModelHistoryKerusakan.fromJson(data))
            .toList();
        setState(() {
          historyKerusakan = test;
          print(historyKerusakan);
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
        backgroundColor: Colors.black,
        title: Text("History Kerusakan"),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'List History Kerusakan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: historyKerusakan.length,
                itemBuilder: (context, index) {
                  final historyItem = historyKerusakan[index];
                  final no_plat = historyItem.no_plat;
                  final jenis_kendaraan = historyItem.jenis_kendaraan;
                  final kerusakan = historyItem.kerusakan;

                  return Container(
                    height: 80,
                    child: Card(
                      color: Color.fromARGB(1, 206, 206, 206),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            16.0), // Atur nilai sesuai keinginan Anda
                      ),
                      child: ListTile(
                        minVerticalPadding: 10.0,
                        title: Text('$no_plat'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '$jenis_kendaraan'), // Use appropriate formatting for DateTime
                            Text('$kerusakan'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
