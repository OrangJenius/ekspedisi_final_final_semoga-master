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

  Future<List<ModelHistoryKerusakan>> getKerusakanData() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.21:1224/laporanKerusakan'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<ModelHistoryKerusakan> kerusakanList = [];
        for (var item in jsonData['data']) {
          kerusakanList.add(ModelHistoryKerusakan.fromJson(item));
        }
        return kerusakanList;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Data Kerusakan Kendaraan'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.black,
        ),
        body: FutureBuilder(
          future: getKerusakanData(),
          builder: (BuildContext context,
              AsyncSnapshot<List<ModelHistoryKerusakan>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  ModelHistoryKerusakan kerusakan = snapshot.data![index];
                  return Container(
                    padding: EdgeInsets.only(top: 16.0),
                    height: 95,
                    child: Card(
                      color: Color.fromARGB(1, 206, 206, 206),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            16.0), // Atur nilai sesuai keinginan Anda
                      ),
                      child: ListTile(
                        minVerticalPadding: 10.0,
                        title: Text('Nomor Plat ${kerusakan.no_plat}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Jenis Kendaraan ${kerusakan.jenis_kendaraan}'), // Use appropriate formatting for DateTime
                            Text('Kerusakan :  ${kerusakan.kerusakan}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
