class UserModel {
  final int id_driver;
  final String driver_name;
  final int phone_number;
  final String Email;
  final String address;
  final String Role;
  final String Password;
  final String Status;

  UserModel({
    required this.Email,
    required this.Role,
    required this.Password,
    required this.Status,
    required this.id_driver,
    required this.driver_name,
    required this.phone_number,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id_driver: json["Id"] ?? 0,
      driver_name: json["nama"] ?? '',
      phone_number: json["nomor_telepon"] ?? 0,
      Email: json["Email"] ?? '',
      address: json["alamat"] ?? '',
      Role: json["Role"] ?? '',
      Password: json["Password"] ?? '',
      Status: json["status"] ?? '',
    );
  }
}
