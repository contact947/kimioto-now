import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/article_model.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../models/gift_model.dart';
import '../models/gift_usage_model.dart';
import 'dart:convert';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  
  late Box<String> _articlesBox;
  late Box<String> _eventsBox;
  late Box<String> _ticketsBox;
  late Box<String> _giftsBox;
  late Box<String> _giftUsagesBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _articlesBox = await Hive.openBox<String>('articles');
    _eventsBox = await Hive.openBox<String>('events');
    _ticketsBox = await Hive.openBox<String>('tickets');
    _giftsBox = await Hive.openBox<String>('gifts');
    _giftUsagesBox = await Hive.openBox<String>('gift_usages');
  }

  // User Management
  Future<void> saveCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Articles
  Future<void> saveArticles(List<ArticleModel> articles) async {
    await _articlesBox.clear();
    for (var article in articles) {
      await _articlesBox.put(article.id, jsonEncode(article.toJson()));
    }
  }

  List<ArticleModel> getArticles() {
    return _articlesBox.values
        .map((json) => ArticleModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  // Events
  Future<void> saveEvents(List<EventModel> events) async {
    await _eventsBox.clear();
    for (var event in events) {
      await _eventsBox.put(event.id, jsonEncode(event.toJson()));
    }
  }

  List<EventModel> getEvents() {
    return _eventsBox.values
        .map((json) => EventModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  // Tickets
  Future<void> saveTicket(TicketModel ticket) async {
    await _ticketsBox.put(ticket.id, jsonEncode(ticket.toJson()));
  }

  List<TicketModel> getTickets() {
    return _ticketsBox.values
        .map((json) => TicketModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  // Gifts
  Future<void> saveGifts(List<GiftModel> gifts) async {
    await _giftsBox.clear();
    for (var gift in gifts) {
      await _giftsBox.put(gift.id, jsonEncode(gift.toJson()));
    }
  }

  List<GiftModel> getGifts() {
    return _giftsBox.values
        .map((json) => GiftModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  // Gift Usages
  Future<void> saveGiftUsage(GiftUsageModel usage) async {
    await _giftUsagesBox.put(usage.id, jsonEncode(usage.toJson()));
  }

  List<GiftUsageModel> getGiftUsages() {
    return _giftUsagesBox.values
        .map((json) => GiftUsageModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }
}
