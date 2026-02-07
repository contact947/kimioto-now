class GiftModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String storeId;
  final String storeName;
  final String city; // 市区町村
  final String prefecture; // 都道府県
  final double latitude;
  final double longitude;
  final int maxUsagePerUser;
  final DateTime? expiryDate;
  final int? minAge;
  final int? maxAge;
  final List<String>? targetSchools; // 対象学校区分
  final DateTime createdAt;

  GiftModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.storeId,
    required this.storeName,
    required this.city,
    required this.prefecture,
    required this.latitude,
    required this.longitude,
    required this.maxUsagePerUser,
    this.expiryDate,
    this.minAge,
    this.maxAge,
    this.targetSchools,
    required this.createdAt,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      storeId: json['store_id'] as String,
      storeName: json['store_name'] as String,
      city: json['city'] as String,
      prefecture: json['prefecture'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      maxUsagePerUser: json['max_usage_per_user'] as int,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      minAge: json['min_age'] as int?,
      maxAge: json['max_age'] as int?,
      targetSchools: json['target_schools'] != null
          ? List<String>.from(json['target_schools'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'store_id': storeId,
      'store_name': storeName,
      'city': city,
      'prefecture': prefecture,
      'latitude': latitude,
      'longitude': longitude,
      'max_usage_per_user': maxUsagePerUser,
      'expiry_date': expiryDate?.toIso8601String(),
      'min_age': minAge,
      'max_age': maxAge,
      'target_schools': targetSchools,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
