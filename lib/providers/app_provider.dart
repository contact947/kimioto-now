import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/article_model.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../models/gift_model.dart';
import '../models/gift_usage_model.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class AppProvider with ChangeNotifier {
  final StorageService _storage;
  
  UserModel? _currentUser;
  List<ArticleModel> _articles = [];
  List<EventModel> _events = [];
  List<TicketModel> _tickets = [];
  List<GiftModel> _gifts = [];
  List<GiftUsageModel> _giftUsages = [];

  AppProvider(this._storage);

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  List<ArticleModel> get articles => _articles;
  List<EventModel> get events => _events;
  List<TicketModel> get tickets => _tickets;
  List<GiftModel> get gifts => _gifts;

  // Initialize
  Future<void> init() async {
    _currentUser = await _storage.getCurrentUser();
    _articles = _storage.getArticles();
    _events = _storage.getEvents();
    _tickets = _storage.getTickets();
    _gifts = _storage.getGifts();
    _giftUsages = _storage.getGiftUsages();
    
    // デモデータ生成
    if (_articles.isEmpty) {
      await _generateDemoData();
    }
    
    notifyListeners();
  }

  // User Management
  Future<void> login(String email, String password) async {
    // デモ用シンプル認証
    final user = UserModel(
      id: const Uuid().v4(),
      name: 'デモユーザー',
      age: 20,
      gender: '男性',
      city: '渋谷区',
      prefecture: '東京都',
      email: email,
      role: email == 'admin@local.beat' ? UserRole.admin : UserRole.user,
      createdAt: DateTime.now(),
    );
    
    await _storage.saveCurrentUser(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> register(UserModel user) async {
    await _storage.saveCurrentUser(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    await _storage.saveCurrentUser(user);
    _currentUser = user;
    notifyListeners();
  }

  // Articles
  List<ArticleModel> getArticlesByCity(String city) {
    return _articles.where((a) => a.city == city).toList()
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
  }

  Future<void> addArticle(ArticleModel article) async {
    _articles.add(article);
    await _storage.saveArticles(_articles);
    notifyListeners();
  }

  Future<void> updateArticle(ArticleModel article) async {
    final index = _articles.indexWhere((a) => a.id == article.id);
    if (index != -1) {
      _articles[index] = article;
      await _storage.saveArticles(_articles);
      notifyListeners();
    }
  }

  Future<void> deleteArticle(String id) async {
    _articles.removeWhere((a) => a.id == id);
    await _storage.saveArticles(_articles);
    notifyListeners();
  }

  // Events
  List<EventModel> getEventsByCity(String city) {
    return _events.where((e) => e.city == city).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  }

  List<EventModel> getUpcomingEvents() {
    final now = DateTime.now();
    return _events.where((e) => e.eventDate.isAfter(now)).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  }

  Future<void> addEvent(EventModel event) async {
    _events.add(event);
    await _storage.saveEvents(_events);
    notifyListeners();
  }

  // Tickets
  List<TicketModel> getUserTickets(String userId) {
    return _tickets.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
  }

  Future<void> purchaseTicket(EventModel event) async {
    if (_currentUser == null) return;
    
    final ticket = TicketModel(
      id: const Uuid().v4(),
      eventId: event.id,
      eventTitle: event.title,
      userId: _currentUser!.id,
      userName: _currentUser!.name,
      qrCode: const Uuid().v4(),
      isUsed: false,
      purchasedAt: DateTime.now(),
    );
    
    _tickets.add(ticket);
    await _storage.saveTicket(ticket);
    
    // イベントの空席を減らす
    final eventIndex = _events.indexWhere((e) => e.id == event.id);
    if (eventIndex != -1) {
      final updatedEvent = EventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        imageUrl: event.imageUrl,
        venue: event.venue,
        city: event.city,
        prefecture: event.prefecture,
        eventDate: event.eventDate,
        ticketPrice: event.ticketPrice,
        totalSeats: event.totalSeats,
        availableSeats: event.availableSeats - 1,
        organizerId: event.organizerId,
        organizerName: event.organizerName,
        createdAt: event.createdAt,
      );
      _events[eventIndex] = updatedEvent;
      await _storage.saveEvents(_events);
    }
    
    notifyListeners();
  }

  // Gifts
  List<GiftModel> getAvailableGifts(Position position) {
    if (_currentUser == null) return [];
    
    var availableGifts = _gifts.where((g) {
      // 使用済みチェック
      final usageCount = _giftUsages
          .where((u) => u.userId == _currentUser!.id && u.giftId == g.id)
          .length;
      if (usageCount >= g.maxUsagePerUser) return false;
      
      // 期限チェック
      if (g.expiryDate != null && g.expiryDate!.isBefore(DateTime.now())) {
        return false;
      }
      
      // 年齢チェック
      if (g.minAge != null && _currentUser!.age < g.minAge!) return false;
      if (g.maxAge != null && _currentUser!.age > g.maxAge!) return false;
      
      return true;
    }).toList();
    
    // 距離でソート
    availableGifts.sort((a, b) {
      final distA = _calculateDistance(
        position.latitude, position.longitude,
        a.latitude, a.longitude,
      );
      final distB = _calculateDistance(
        position.latitude, position.longitude,
        b.latitude, b.longitude,
      );
      return distA.compareTo(distB);
    });
    
    return availableGifts;
  }

  Future<void> useGift(String giftId) async {
    if (_currentUser == null) return;
    
    final usage = GiftUsageModel(
      id: const Uuid().v4(),
      giftId: giftId,
      userId: _currentUser!.id,
      usedAt: DateTime.now(),
    );
    
    _giftUsages.add(usage);
    await _storage.saveGiftUsage(usage);
    notifyListeners();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // 地球の半径 (km)
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // デモデータ生成
  Future<void> _generateDemoData() async {
    // デモ記事
    _articles = [
      ArticleModel(
        id: const Uuid().v4(),
        title: '渋谷の新しいカフェがオープン',
        content: '渋谷駅から徒歩5分の場所に、おしゃれなカフェがオープンしました。学生向けの割引も実施中です。',
        category: '店舗',
        imageUrl: 'https://picsum.photos/seed/cafe1/400/300',
        authorId: 'admin',
        authorName: '編集部',
        city: '渋谷区',
        prefecture: '東京都',
        viewCount: 150,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ArticleModel(
        id: const Uuid().v4(),
        title: '地域の音楽イベント開催決定',
        content: '来月、渋谷で大規模な音楽イベントが開催されます。地元のバンドも出演予定です。',
        category: 'イベント',
        imageUrl: 'https://picsum.photos/seed/music1/400/300',
        authorId: 'admin',
        authorName: '編集部',
        city: '渋谷区',
        prefecture: '東京都',
        viewCount: 230,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ArticleModel(
        id: const Uuid().v4(),
        title: '商店街でフリーマーケット開催',
        content: '毎月第3土曜日に、商店街でフリーマーケットが開催されています。掘り出し物が見つかるかも!',
        category: 'イベント',
        imageUrl: 'https://picsum.photos/seed/market1/400/300',
        authorId: 'admin',
        authorName: '編集部',
        city: '渋谷区',
        prefecture: '東京都',
        viewCount: 95,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    await _storage.saveArticles(_articles);

    // デモイベント
    _events = [
      EventModel(
        id: const Uuid().v4(),
        title: '渋谷ストリートライブ 2024',
        description: '地元のアーティストが集結!熱いライブパフォーマンスをお届けします。',
        imageUrl: 'https://picsum.photos/seed/event1/400/300',
        venue: '渋谷公会堂',
        city: '渋谷区',
        prefecture: '東京都',
        eventDate: DateTime.now().add(const Duration(days: 14)),
        ticketPrice: 2500,
        totalSeats: 500,
        availableSeats: 342,
        organizerId: 'org1',
        organizerName: '渋谷イベント実行委員会',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      EventModel(
        id: const Uuid().v4(),
        title: '地域交流フェスティバル',
        description: '地域の魅力を再発見!飲食ブース、ワークショップ、ステージイベントなど盛りだくさん。',
        imageUrl: 'https://picsum.photos/seed/event2/400/300',
        venue: '渋谷区民会館',
        city: '渋谷区',
        prefecture: '東京都',
        eventDate: DateTime.now().add(const Duration(days: 21)),
        ticketPrice: 1000,
        totalSeats: 300,
        availableSeats: 280,
        organizerId: 'org2',
        organizerName: '地域まちづくり協議会',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
    await _storage.saveEvents(_events);

    // デモギフト
    _gifts = [
      GiftModel(
        id: const Uuid().v4(),
        title: 'カフェドリンク50%オフ',
        description: 'すべてのドリンクが半額!学生限定の特別オファーです。',
        imageUrl: 'https://picsum.photos/seed/gift1/400/300',
        storeId: 'store1',
        storeName: 'カフェ・ローカル',
        city: '渋谷区',
        prefecture: '東京都',
        latitude: 35.6595,
        longitude: 139.7004,
        maxUsagePerUser: 1,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        minAge: 17,
        maxAge: 24,
        targetSchools: ['高校生', '大学生'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      GiftModel(
        id: const Uuid().v4(),
        title: '書店10%オフクーポン',
        description: '全商品10%オフ!好きな本を見つけよう。',
        imageUrl: 'https://picsum.photos/seed/gift2/400/300',
        storeId: 'store2',
        storeName: 'ブックストア渋谷',
        city: '渋谷区',
        prefecture: '東京都',
        latitude: 35.6612,
        longitude: 139.7008,
        maxUsagePerUser: 2,
        expiryDate: DateTime.now().add(const Duration(days: 60)),
        minAge: null,
        maxAge: null,
        targetSchools: null,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    await _storage.saveGifts(_gifts);
  }
}
