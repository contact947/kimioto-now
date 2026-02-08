class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String organizer;
  final String imageUrl;
  final String city; // 市区町村
  final String prefecture; // 都道府県

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.organizer,
    required this.imageUrl,
    required this.city,
    required this.prefecture,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      organizer: json['organizer'] as String,
      imageUrl: json['image_url'] as String,
      city: json['city'] as String,
      prefecture: json['prefecture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'image_url': imageUrl,
      'city': city,
      'prefecture': prefecture,
    };
  }
}
