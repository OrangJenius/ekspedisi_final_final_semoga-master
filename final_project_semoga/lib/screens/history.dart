import 'package:flutter/material.dart';
import 'package:final_project_semoga/screens/detailHistory.dart';
import 'package:final_project_semoga/model/historyModel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    Key? key,
    required this.historyID,
  }) : super(key: key);
  final List<HistoryModel> historyID;

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? selectedFilter = 'Filter By';

  List<HistoryModel> sortHistoryList(String filter) {
    List<HistoryModel> sortedList = List.from(widget.historyID);

    if (filter == 'By Date') {
      sortedList.sort((a, b) => a.tanggalSampai.compareTo(b.tanggalSampai));
    } else if (filter == 'By Destination') {
      sortedList.sort((a, b) => a.alamatTujuan.compareTo(b.alamatTujuan));
    } else if (filter == 'By Order Name') {
      sortedList.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    }

    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("History"),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedFilter,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedFilter = newValue;
                          });
                        },
                        items: <String>[
                          'Filter By',
                          'By Date',
                          'By Destination',
                          'By Order Name'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        underline: Container(
                          height: 2,
                          color: Colors.grey[400],
                        ),
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Use ListView.builder to dynamically generate cards
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: sortHistoryList(selectedFilter!).length,
                itemBuilder: (context, index) {
                  final historyItem = sortHistoryList(selectedFilter!)[index];
                  final orderNumber = historyItem.orderNumber;
                  final tujuan = historyItem.alamatTujuan;
                  return Container(
                    height: 80,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            16.0), // Atur nilai sesuai keinginan Anda
                      ),
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
                            Text(historyItem.tanggalSampai
                                .toString()), // Use appropriate formatting for DateTime
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
                                  historyID: historyItem,
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
        ],
      ),
    );
  }
}
