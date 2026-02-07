class UserModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String city; // 市区町村
  final String prefecture; // 都道府県
  final String email;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.city,
    required this.prefecture,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      city: json['city'] as String,
      prefecture: json['prefecture'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.user,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'city': city,
      'prefecture': prefecture,
      'email': email,
      'role': role.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum UserRole {
  user,
  admin,
  planner,
}
