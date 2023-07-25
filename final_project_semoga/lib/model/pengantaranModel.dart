class PengantaranModel {
  final int orderNumber;
  final DateTime jadwalPengantaran;
  final String tujuan;

  PengantaranModel({
    required this.orderNumber,
    required this.jadwalPengantaran,
    required this.tujuan,
  });

  factory PengantaranModel.fromJson(Map<String, dynamic> json) {
    return PengantaranModel(
      orderNumber:
          json['ekspedisi_Id'] ?? 0, // Assuming ekspedisi_Id is of type int
      jadwalPengantaran:
          DateTime.parse(json['ekspedisi_tanggal_pengiriman'] ?? ''),
      tujuan: json['ekspedisi_kota_tujuan'] ?? '',
    );
  }
}
