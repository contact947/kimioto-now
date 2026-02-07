class EventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String venue;
  final String city; // 市区町村
  final String prefecture; // 都道府県
  final DateTime eventDate;
  final double ticketPrice;
  final int totalSeats;
  final int availableSeats;
  final String organizerId;
  final String organizerName;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.venue,
    required this.city,
    required this.prefecture,
    required this.eventDate,
    required this.ticketPrice,
    required this.totalSeats,
    required this.availableSeats,
    required this.organizerId,
    required this.organizerName,
    required this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      venue: json['venue'] as String,
      city: json['city'] as String,
      prefecture: json['prefecture'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      ticketPrice: (json['ticket_price'] as num).toDouble(),
      totalSeats: json['total_seats'] as int,
      availableSeats: json['available_seats'] as int,
      organizerId: json['organizer_id'] as String,
      organizerName: json['organizer_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'venue': venue,
      'city': city,
      'prefecture': prefecture,
      'event_date': eventDate.toIso8601String(),
      'ticket_price': ticketPrice,
      'total_seats': totalSeats,
      'available_seats': availableSeats,
      'organizer_id': organizerId,
      'organizer_name': organizerName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
