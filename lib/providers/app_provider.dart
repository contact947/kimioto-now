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
    
    debugPrint('✅ AppProvider initialization complete');
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
}
