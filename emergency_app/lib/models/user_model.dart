class UserModel {
  final String? id;
  final String username;
  final String? password;
  final String? fullName;
  final String? address;
  final String? phone;
  final String? email;
  final String? currentCity;
  final String? currentCountry;
  final String? hotelName;

  UserModel({
    this.id,
    required this.username,
    this.password,
    this.fullName,
    this.address,
    this.phone,
    this.email,
    this.currentCity,
    this.currentCountry,
    this.hotelName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      username: json['username'] ?? '',
      password: json['password'],
      fullName: json['full_name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      currentCity: json['current_city'],
      currentCountry: json['current_country'],
      hotelName: json['hotel_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'full_name': fullName,
      'address': address,
      'phone': phone,
      'email': email,
      'current_city': currentCity,
      'current_country': currentCountry,
      'hotel_name': hotelName,
    };
  }
}
