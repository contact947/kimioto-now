class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String category; // 店舗、イベント、インタビュー等
  final String imageUrl;
  final String authorId;
  final String authorName;
  final String city; // 市区町村
  final String prefecture; // 都道府県
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.city,
    required this.prefecture,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      city: json['city'] as String,
      prefecture: json['prefecture'] as String,
      viewCount: json['view_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'image_url': imageUrl,
      'author_id': authorId,
      'author_name': authorName,
      'city': city,
      'prefecture': prefecture,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
