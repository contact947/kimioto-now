import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../models/article_model.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../models/gift_model.dart';
import '../models/gift_usage_model.dart';
import '../services/storage_service.dart';
import '../services/firebase_firestore_service.dart';
import 'package:uuid/uuid.dart';

class AppProvider with ChangeNotifier {
  final StorageService _storage;
  final FirebaseFirestoreService _firestore;
  
  UserModel? _currentUser;
  List<ArticleModel> _articles = [];
  List<EventModel> _events = [];
  List<TicketModel> _tickets = [];
  List<GiftModel> _gifts = [];
  List<GiftUsageModel> _giftUsages = [];

  // Stream subscriptions
  StreamSubscription<List<ArticleModel>>? _articlesSubscription;
  StreamSubscription<List<EventModel>>? _eventsSubscription;
  StreamSubscription<List<TicketModel>>? _ticketsSubscription;
  StreamSubscription<List<GiftModel>>? _giftsSubscription;
  StreamSubscription<List<GiftUsageModel>>? _giftUsagesSubscription;

  AppProvider(this._storage, this._firestore);

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isPlanner => _currentUser?.role == UserRole.planner || isAdmin;
  List<ArticleModel> get articles => _articles;
  List<EventModel> get events => _events;
  List<TicketModel> get tickets => _tickets;
  List<GiftModel> get gifts => _gifts;

  // Initialize
  Future<void> init() async {
    debugPrint('🔥 Initializing Firebase AppProvider...');
    
    // Load current user from local storage
    _currentUser = await _storage.getCurrentUser();
    if (_currentUser != null) {
      debugPrint('✅ Loaded user from local storage: ${_currentUser!.email}');
    }
    
    // Subscribe to Firestore streams
    _subscribeToFirestore();
    
    // Wait a moment for initial data load
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generate demo data if Firebase is empty
    await _checkAndGenerateDemoData();
    
    debugPrint('✅ AppProvider initialization complete');
  }
  
  Future<void> _checkAndGenerateDemoData() async {
    // Check if we already have data in Firestore
    if (_articles.isEmpty && _events.isEmpty) {
      debugPrint('📝 No data found in Firestore. Generating demo data...');
      await _generateDemoData();
      debugPrint('✅ Demo data generation complete');
    } else {
      debugPrint('✅ Data already exists in Firestore (${_articles.length} articles, ${_events.length} events)');
    }
  }

  void _subscribeToFirestore() {
    debugPrint('📡 Subscribing to Firestore streams...');
    
    // Articles stream
    _articlesSubscription = _firestore.getArticlesStream().listen(
      (articles) {
        _articles = articles;
        debugPrint('📰 Received ${articles.length} articles from Firestore');
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error in articles stream: $error');
      },
    );

    // Events stream
    _eventsSubscription = _firestore.getEventsStream().listen(
      (events) {
        _events = events;
        debugPrint('🎫 Received ${events.length} events from Firestore');
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error in events stream: $error');
      },
    );

    // Tickets stream
    _ticketsSubscription = _firestore.getTicketsStream().listen(
      (tickets) {
        _tickets = tickets;
        debugPrint('🎟️ Received ${tickets.length} tickets from Firestore');
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error in tickets stream: $error');
      },
    );

    // Gifts stream
    _giftsSubscription = _firestore.getGiftsStream().listen(
      (gifts) {
        _gifts = gifts;
        debugPrint('🎁 Received ${gifts.length} gifts from Firestore');
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error in gifts stream: $error');
      },
    );

    // Gift usages stream
    _giftUsagesSubscription = _firestore.getGiftUsagesStream().listen(
      (usages) {
        _giftUsages = usages;
        debugPrint('📊 Received ${usages.length} gift usages from Firestore');
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error in gift usages stream: $error');
      },
    );
  }

  @override
  void dispose() {
    _articlesSubscription?.cancel();
    _eventsSubscription?.cancel();
    _ticketsSubscription?.cancel();
    _giftsSubscription?.cancel();
    _giftUsagesSubscription?.cancel();
    super.dispose();
  }

  // ========== User Management ==========
  
  Future<void> login(String email, String password) async {
    debugPrint('🔐 Attempting login for: $email');
    
    // Get user from Firestore
    UserModel? user = await _firestore.getUserByEmail(email);
    
    if (user == null) {
      // Create demo user if not exists
      user = UserModel(
        id: const Uuid().v4(),
        name: email == 'admin@local.beat' ? '管理者' : 'デモユーザー',
        age: 20,
        gender: '男性',
        city: '渋谷区',
        prefecture: '東京都',
        email: email,
        role: email == 'admin@local.beat' ? UserRole.admin : UserRole.user,
        createdAt: DateTime.now(),
      );
      
      // Save to Firestore
      await _firestore.saveUser(user);
      debugPrint('✅ Created new user in Firestore: ${user.email}');
    }
    
    // Save to local storage
    await _storage.saveCurrentUser(user);
    _currentUser = user;
    
    debugPrint('✅ Login successful: ${user.email} (${user.role})');
    notifyListeners();
  }

  Future<void> register(UserModel user) async {
    debugPrint('📝 Registering new user: ${user.email}');
    
    // Save to Firestore
    await _firestore.saveUser(user);
    
    // Save to local storage
    await _storage.saveCurrentUser(user);
    _currentUser = user;
    
    debugPrint('✅ Registration successful: ${user.email}');
    notifyListeners();
  }

  Future<void> logout() async {
    debugPrint('👋 Logging out user: ${_currentUser?.email}');
    
    await _storage.logout();
    _currentUser = null;
    
    debugPrint('✅ Logout successful');
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    debugPrint('🔄 Updating user: ${user.email}');
    
    // Update in Firestore
    await _firestore.saveUser(user);
    
    // Update local storage
    await _storage.saveCurrentUser(user);
    _currentUser = user;
    
    debugPrint('✅ User updated successfully');
    notifyListeners();
  }

  // ========== Articles ==========
  
  List<ArticleModel> getArticlesByCity(String city) {
    return _articles.where((a) => a.city == city).toList()
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
  }

  Future<void> addArticle(ArticleModel article) async {
    debugPrint('📝 Adding article: ${article.title}');
    await _firestore.saveArticle(article);
    debugPrint('✅ Article added successfully');
  }

  Future<void> updateArticle(ArticleModel article) async {
    debugPrint('🔄 Updating article: ${article.title}');
    await _firestore.saveArticle(article);
    debugPrint('✅ Article updated successfully');
  }

  Future<void> deleteArticle(String id) async {
    debugPrint('🗑️ Deleting article: $id');
    await _firestore.deleteArticle(id);
    debugPrint('✅ Article deleted successfully');
  }

  // ========== Events ==========
  
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
    debugPrint('🎫 Adding event: ${event.title}');
    await _firestore.saveEvent(event);
    debugPrint('✅ Event added successfully');
  }

  Future<void> updateEvent(EventModel event) async {
    debugPrint('🔄 Updating event: ${event.title}');
    await _firestore.saveEvent(event);
    debugPrint('✅ Event updated successfully');
  }

  Future<void> deleteEvent(String id) async {
    debugPrint('🗑️ Deleting event: $id');
    await _firestore.deleteEvent(id);
    debugPrint('✅ Event deleted successfully');
  }

  // ========== Tickets ==========
  
  List<TicketModel> getUserTickets(String userId) {
    return _tickets.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
  }

  Future<void> purchaseTicket(EventModel event) async {
    if (_currentUser == null) {
      debugPrint('❌ Cannot purchase ticket: User not logged in');
      return;
    }
    
    debugPrint('🎟️ Purchasing ticket for event: ${event.title}');
    
    final ticket = TicketModel(
      id: const Uuid().v4(),
      eventId: event.id,
      eventTitle: event.title,
      userId: _currentUser!.id,
      userName: _currentUser!.name,
      qrCode: const Uuid().v4(),
      isUsed: false,
      purchasedAt: DateTime.now(),
      usedAt: null,
    );
    
    // Save ticket to Firestore
    await _firestore.saveTicket(ticket);
    
    // Update event available seats
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
    await _firestore.saveEvent(updatedEvent);
    
    debugPrint('✅ Ticket purchased successfully');
  }

  Future<void> useTicket(String qrCode) async {
    debugPrint('🎫 Using ticket with QR code: $qrCode');
    
    final ticket = _tickets.firstWhere(
      (t) => t.qrCode == qrCode,
      orElse: () => TicketModel(
        id: '',
        eventId: '',
        eventTitle: '',
        userId: '',
        userName: '',
        qrCode: '',
        isUsed: false,
        purchasedAt: DateTime.now(),
        usedAt: null,
      ),
    );
    
    if (ticket.id.isEmpty) {
      debugPrint('❌ Ticket not found');
      return;
    }
    
    if (ticket.isUsed) {
      debugPrint('❌ Ticket already used');
      return;
    }
    
    // Update ticket
    final updatedTicket = TicketModel(
      id: ticket.id,
      eventId: ticket.eventId,
      eventTitle: ticket.eventTitle,
      userId: ticket.userId,
      userName: ticket.userName,
      qrCode: ticket.qrCode,
      isUsed: true,
      purchasedAt: ticket.purchasedAt,
      usedAt: DateTime.now(),
    );
    
    await _firestore.saveTicket(updatedTicket);
    debugPrint('✅ Ticket used successfully');
  }

  // ========== Gifts ==========
  
  List<GiftModel> getAvailableGifts(UserModel user) {
    final now = DateTime.now();
    return _gifts.where((g) {
      // Check expiry
      if (g.expiryDate != null && g.expiryDate!.isBefore(now)) return false;
      
      // Check age restrictions
      if (g.minAge != null && user.age < g.minAge!) return false;
      if (g.maxAge != null && user.age > g.maxAge!) return false;
      
      // Check usage limit
      final userUsages = _giftUsages.where(
        (u) => u.giftId == g.id && u.userId == user.id,
      ).length;
      if (userUsages >= g.maxUsagePerUser) return false;
      
      return true;
    }).toList();
  }

  Future<void> useGift(String giftId) async {
    if (_currentUser == null) {
      debugPrint('❌ Cannot use gift: User not logged in');
      return;
    }
    
    debugPrint('🎁 Using gift: $giftId');
    
    final usage = GiftUsageModel(
      id: const Uuid().v4(),
      giftId: giftId,
      userId: _currentUser!.id,
      usedAt: DateTime.now(),
    );
    
    await _firestore.saveGiftUsage(usage);
    debugPrint('✅ Gift used successfully');
  }

  int getGiftUsageCount(String giftId, String userId) {
    return _giftUsages.where(
      (u) => u.giftId == giftId && u.userId == userId,
    ).length;
  }
  
  // ========== Demo Data Generation ==========
  
  Future<void> _generateDemoData() async {
    debugPrint('🎬 Generating demo data for Firebase...');
    
    final uuid = const Uuid();
    final now = DateTime.now();
    
    // Generate demo articles
    final demoArticles = [
      ArticleModel(
        id: uuid.v4(),
        title: '渋谷の新しいカフェがオープン',
        content: '渋谷駅から徒歩5分の場所に、地元の食材を使った新しいカフェがオープンしました。',
        category: '店舗',
        imageUrl: 'https://picsum.photos/seed/cafe1/400/300',
        authorId: 'demo-author-1',
        authorName: '編集部',
        city: '渋谷区',
        prefecture: '東京都',
        viewCount: 150,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ArticleModel(
        id: uuid.v4(),
        title: '地域の音楽イベント開催決定',
        content: '来月、地域の若者たちによる音楽イベントが開催されます。',
        category: 'イベント',
        imageUrl: 'https://picsum.photos/seed/music1/400/300',
        authorId: 'demo-author-1',
        authorName: '編集部',
        city: '渋谷区',
        prefecture: '東京都',
        viewCount: 230,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ArticleModel(
        id: uuid.v4(),
        title: '商店街でフリーマーケット開催',
        content: '週末に地域の商店街でフリーマーケットが開催されます。',
        category: 'イベント',
        imageUrl: 'https://picsum.photos/seed/market1/400/300',
        authorId: 'demo-author-1',
        authorName: '編集部',
        city: '渋谷区',
        prefecture: '東京都',
        viewCount: 95,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
    
    // Generate demo events
    final demoEvents = [
      EventModel(
        id: uuid.v4(),
        title: '渋谷ストリートライブ 2024',
        description: '地域の若手アーティストによるストリートライブイベント',
        imageUrl: 'https://picsum.photos/seed/event1/400/300',
        venue: '渋谷公会堂',
        city: '渋谷区',
        prefecture: '東京都',
        eventDate: now.add(const Duration(days: 14)),
        ticketPrice: 2500,
        totalSeats: 500,
        availableSeats: 342,
        organizerId: 'demo-organizer-1',
        organizerName: '渋谷イベント実行委員会',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      EventModel(
        id: uuid.v4(),
        title: '地域交流フェスティバル',
        description: '地域住民の交流を深めるフェスティバル',
        imageUrl: 'https://picsum.photos/seed/event2/400/300',
        venue: '渋谷区民会館',
        city: '渋谷区',
        prefecture: '東京都',
        eventDate: now.add(const Duration(days: 21)),
        ticketPrice: 1000,
        totalSeats: 300,
        availableSeats: 280,
        organizerId: 'demo-organizer-2',
        organizerName: '地域まちづくり協議会',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
    
    // Generate demo gifts
    final demoGifts = [
      GiftModel(
        id: uuid.v4(),
        title: 'カフェドリンク50%オフ',
        description: '対象ドリンク全品50%オフ',
        imageUrl: 'https://picsum.photos/seed/cafe-gift1/400/300',
        storeId: 'store-cafe-local',
        storeName: 'カフェ・ローカル',
        city: '渋谷区',
        prefecture: '東京都',
        latitude: 35.6595,
        longitude: 139.7004,
        maxUsagePerUser: 1,
        expiryDate: now.add(const Duration(days: 30)),
        minAge: 17,
        maxAge: 24,
        targetSchools: ['高校生', '大学生'],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      GiftModel(
        id: uuid.v4(),
        title: '書店10%オフクーポン',
        description: '全商品10%オフ',
        imageUrl: 'https://picsum.photos/seed/book-gift1/400/300',
        storeId: 'store-bookstore',
        storeName: 'ブックストア渋谷',
        city: '渋谷区',
        prefecture: '東京都',
        latitude: 35.6612,
        longitude: 139.7008,
        maxUsagePerUser: 2,
        expiryDate: now.add(const Duration(days: 60)),
        minAge: null,
        maxAge: null,
        targetSchools: null,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
    
    // Save to Firestore
    debugPrint('📝 Saving ${demoArticles.length} demo articles...');
    for (var article in demoArticles) {
      await _firestore.saveArticle(article);
    }
    
    debugPrint('🎫 Saving ${demoEvents.length} demo events...');
    for (var event in demoEvents) {
      await _firestore.saveEvent(event);
    }
    
    debugPrint('🎁 Saving ${demoGifts.length} demo gifts...');
    for (var gift in demoGifts) {
      await _firestore.saveGift(gift);
    }
    
    debugPrint('✅ Demo data saved to Firestore successfully!');
  }
}
