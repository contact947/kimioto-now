class TicketModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String userId;
  final String userName;
  final String qrCode;
  final bool isUsed;
  final DateTime? usedAt;
  final DateTime purchasedAt;

  TicketModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.userName,
    required this.qrCode,
    required this.isUsed,
    this.usedAt,
    required this.purchasedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      eventTitle: json['event_title'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      qrCode: json['qr_code'] as String,
      isUsed: json['is_used'] as bool,
      usedAt: json['used_at'] != null 
          ? DateTime.parse(json['used_at'] as String)
          : null,
      purchasedAt: DateTime.parse(json['purchased_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'event_title': eventTitle,
      'user_id': userId,
      'user_name': userName,
      'qr_code': qrCode,
      'is_used': isUsed,
      'used_at': usedAt?.toIso8601String(),
      'purchased_at': purchasedAt.toIso8601String(),
    };
  }
}
