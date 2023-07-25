class HistoryModel {
  final int orderNumber;
  final DateTime tanggalSampai;
  final String tujuan;

  HistoryModel({
    required this.orderNumber,
    required this.tanggalSampai,
    required this.tujuan,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      orderNumber:
          json['ekspedisi_Id'] ?? 0, // Assuming ekspedisi_Id is of type int
      tanggalSampai: DateTime.parse(json['tanggal_sampai'] ?? ''),
      tujuan: json['kota_tujuan'] ?? '',
    );
  }
}
