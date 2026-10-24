class UserModel {
  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  UserModel({
    this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int?,
    email: json['email'] ?? '',
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    avatar: json['avatar'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
  };

  String get fullName => '$firstName $lastName'.trim();
}