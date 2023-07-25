import 'dart:convert';

import 'package:final_project_semoga/model/historyModel.dart';
import 'package:flutter/material.dart';
import 'package:final_project_semoga/screens/profile.dart';
import 'package:final_project_semoga/screens/detailPengantaran.dart';
import 'package:final_project_semoga/screens/detailHistory.dart';
import 'package:final_project_semoga/screens/history.dart';
import 'package:http/http.dart' as http;
import 'package:final_project_semoga/model/pengantaranModel.dart';

class HomeScreen extends StatefulWidget {
  final String userID;
  HomeScreen({required this.userID});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PengantaranModel> pengantaranData = [];

  List<HistoryModel> historyData = [];

  @override
  void initState() {
    super.initState();
    fetchPengantaranData(); // Fetch pengantaran data from API when the screen initializes
    fetchHistoryData(); // Fetch history data from API when the screen initializes
  }

  Future<void> fetchPengantaranData() async {
    final apiUrl = 'http://10.5.50.150:1224/pengiriman/${widget.userID}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Successfully fetched data from the API
        // Parse the response body, which should be a list of Map<String, dynamic>
        List<Map<String, dynamic>> apiPengantaranData =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        List<PengantaranModel> pengantaranModel = apiPengantaranData
            .map((data) => PengantaranModel.fromJson(data))
            .toList();
        setState(() {
          pengantaranData = pengantaranModel;
          print(pengantaranData);
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

  Future<void> fetchHistoryData() async {
    final apiUrl = 'http://10.5.50.150:1224/historyDriver/${widget.userID}';
    // Simulate API call and fetch history data
    // Replace this with your actual API call to fetch the history data
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Successfully fetched data from the API
        // Parse the response body, which should be a list of Map<String, dynamic>
        List<Map<String, dynamic>> apiHistoryData =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        List<HistoryModel> historyModel =
            apiHistoryData.map((data) => HistoryModel.fromJson(data)).toList();
        setState(() {
          historyData = historyModel;
          //print(historyData);
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
        leading: IconButton(
          icon: Icon(
            Icons.account_circle,
            size: 35.0,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'List Pengantaran',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Generate cards for List Pengantaran section using ListView.builder
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: pengantaranData.length,
                itemBuilder: (context, index) {
                  final pengantaranItem = pengantaranData[index];
                  final orderNumber = pengantaranItem.orderNumber;
                  final jadwalPengantaran = pengantaranItem.jadwalPengantaran;
                  final tujuan = pengantaranItem.tujuan;

                  return Container(
                    height: 80,
                    child: Card(
                      color: Color.fromARGB(1, 206, 206, 206),
                      child: ListTile(
                        minVerticalPadding: 10.0,
                        leading: CircleAvatar(
                          child:
                              Icon(Icons.image), // Replace with your thumbnail
                        ),
                        title: Text('$orderNumber'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${jadwalPengantaran.toString()}'), // Use appropriate formatting for DateTime
                            Text('$tujuan'),
                          ],
                        ),
                        trailing: IconButton(
                          alignment: Alignment.topCenter,
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPengantaranScreen(
                                  userID: widget.userID,
                                  pengantaranItem: pengantaranItem,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'History',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Generate cards for History section using ListView.builder
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: historyData.length,
            itemBuilder: (context, index) {
              final data = historyData[index];
              final orderNumber = data.orderNumber;
              print(orderNumber);
              final tanggalSampai = data.tanggalSampai;
              print(tanggalSampai);
              final tujuan = data.alamatTujuan;
              print(tujuan);

              return Container(
                height: 80,
                child: Card(
                  color: Color.fromARGB(1, 206, 206, 206),
                  child: ListTile(
                    minVerticalPadding: 10.0,
                    leading: CircleAvatar(
                      child: Icon(Icons.image), // Replace with your thumbnail
                    ),
                    title: Text('$orderNumber'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${tanggalSampai.toString()}'), // Use appropriate formatting for DateTime
                        Text('$tujuan'),
                      ],
                    ),
                    trailing: IconButton(
                      alignment: Alignment.topCenter,
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailHistoryScreen(
                              historyID: data,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HistoryScreen(
                            historyID: historyData,
                          )),
                );
              },
              child: Text(
                'View More',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
