class GiftUsageModel {
  final String id;
  final String giftId;
  final String userId;
  final DateTime usedAt;

  GiftUsageModel({
    required this.id,
    required this.giftId,
    required this.userId,
    required this.usedAt,
  });

  factory GiftUsageModel.fromJson(Map<String, dynamic> json) {
    return GiftUsageModel(
      id: json['id'] as String,
      giftId: json['gift_id'] as String,
      userId: json['user_id'] as String,
      usedAt: DateTime.parse(json['used_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gift_id': giftId,
      'user_id': userId,
      'used_at': usedAt.toIso8601String(),
    };
  }
}
