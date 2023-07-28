class ProfileModel {
  final int id_driver;
  final String driver_name;
  final String phone_number;
  final String address;

  ProfileModel({
    required this.id_driver,
    required this.driver_name,
    required this.phone_number,
    required this.address,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      address: json["alamat"] ?? '',
      id_driver: json["id"] ?? 0,
      driver_name: json["nama"] ?? '',
      phone_number: json["nomor_telepon"] ?? '',
    );
  }
}
