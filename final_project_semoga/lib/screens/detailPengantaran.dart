import 'package:flutter/material.dart';
import 'package:final_project_semoga/screens/pengiriman.dart';

import '../model/pengantaranModel.dart';

class DetailPengantaranScreen extends StatefulWidget {
  final String userID;
  final PengantaranModel pengantaranItem;

  DetailPengantaranScreen({
    required this.userID,
    required this.pengantaranItem,
  });

  @override
  _DetailPengantaranScreenState createState() =>
      _DetailPengantaranScreenState();
}

class _DetailPengantaranScreenState extends State<DetailPengantaranScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Pengantaran'),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0),
          child: Column(
            children: [
              Card(
                color: const Color.fromARGB(1, 206, 206, 206),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: Text(
                          '${widget.pengantaranItem.orderNumber}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Driver',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${widget.pengantaranItem.user_nama}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Jenis Kendaraan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                          '${widget.pengantaranItem.kendaraan_jenis_kendaraan}'),
                    ),
                    ListTile(
                      title: Text(
                        'Nomor Plat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                          '${widget.pengantaranItem.kendaraan_nomor_plat}'),
                    ),
                    ListTile(
                      title: Text(
                        'Jenis Barang',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('${widget.pengantaranItem.barang_jenis}'),
                    ),
                    ListTile(
                      title: Text(
                        'Alamat Asal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle:
                          Text('${widget.pengantaranItem.ekspedisi_kota_asal}'),
                    ),
                    ListTile(
                      title: Text(
                        'Alamat Tujuan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('${widget.pengantaranItem.tujuan}'),
                    ),
                    ListTile(
                      title: Text(
                        'Tanggal Pengantaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle:
                          Text('${widget.pengantaranItem.jadwalPengantaran}'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Pengiriman(
                                userID: widget.userID,
                                pengantaranItem: widget.pengantaranItem,
                              )),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(120.0, 50.0),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Start'),
                ),
              ),
            ],
          ),
        ));
  }
}
