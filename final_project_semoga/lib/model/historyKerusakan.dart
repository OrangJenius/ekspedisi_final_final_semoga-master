class ModelHistoryKerusakan {
  final String no_plat;
  final String jenis_kendaraan;
  final String kerusakan;

  ModelHistoryKerusakan(
      {required this.no_plat,
      required this.jenis_kendaraan,
      required this.kerusakan});

  factory ModelHistoryKerusakan.fromJson(Map<String, dynamic> json) {
    return ModelHistoryKerusakan(
      no_plat: json['nomer_plat'],
      jenis_kendaraan: json['jenis_kendaraan'],
      kerusakan: json['kerusakan'],
    );
  }
}
