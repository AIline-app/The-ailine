class UserModel {
  final String username;
  final String phone;
  final String typeAuto;
  final String numberAuto;
  final String role;

  UserModel({
    required this.username,
    required this.phone,
    required this.typeAuto,
    required this.numberAuto,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      phone: json['phone'],
      typeAuto: json['type_auto'],
      numberAuto: json['number_auto'],
      role: json['role'],
    );
  }
}