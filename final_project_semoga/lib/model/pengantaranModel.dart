class PengantaranModel {
  final int orderNumber;
  final DateTime jadwalPengantaran;
  final String tujuan;
  final String user_nama;
  final String client_nama;
  final String kendaraan_jenis_kendaraan;
  final String kendaraan_nomor_plat;
  final String barang_jenis;
  final String client_alamat;
  final String ekspedisi_kota_asal;
  final int kendaraan_id;

  PengantaranModel({
    required this.orderNumber,
    required this.jadwalPengantaran,
    required this.tujuan,
    required this.user_nama,
    required this.client_nama,
    required this.kendaraan_jenis_kendaraan,
    required this.kendaraan_nomor_plat,
    required this.barang_jenis,
    required this.client_alamat,
    required this.ekspedisi_kota_asal,
    required this.kendaraan_id,
  });

  factory PengantaranModel.fromJson(Map<String, dynamic> json) {
    return PengantaranModel(
      orderNumber:
          json['ekspedisi_Id'] ?? 0, // Assuming ekspedisi_Id is of type int
      jadwalPengantaran:
          DateTime.parse(json['ekspedisi_tanggal_pengiriman'] ?? ''),
      tujuan: json['ekspedisi_kota_tujuan'] ?? '',
      user_nama: json['user_nama'],
      client_nama: json['client_nama'],
      kendaraan_jenis_kendaraan: json['kendaraan_jenis_kendaraan'],
      kendaraan_nomor_plat: json['kendaraan_nomor_plat'],
      barang_jenis: json['barang_jenis'],
      client_alamat: json['client_alamat'],
      ekspedisi_kota_asal: json['ekspedisi_kota_asal'],
      kendaraan_id: json['kendaraan_id'],
    );
  }
}
