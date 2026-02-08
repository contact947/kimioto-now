import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/article_model.dart';
import '../models/event_model.dart';
import '../models/gift_model.dart';
import '../models/gift_usage_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class StorageService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Web環境ではHiveを使わず、メモリストレージを使用
  final Map<String, String> _memoryArticles = {};
  final Map<String, String> _memoryEvents = {};
  final Map<String, String> _memoryGifts = {};
  final Map<String, String> _memoryGiftUsages = {};
  
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    if (kIsWeb) {
      // Web環境ではメモリストレージのみ使用
      debugPrint('Using memory storage for Web');
      _isInitialized = true;
    } else {
      // モバイル環境（現在未使用）
      _isInitialized = true;
    }
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
    if (kIsWeb) {
      _memoryArticles.clear();
      for (var article in articles) {
        _memoryArticles[article.id] = jsonEncode(article.toJson());
      }
    }
  }

  List<ArticleModel> getArticles() {
    if (kIsWeb) {
      return _memoryArticles.values
          .map((json) => ArticleModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Events
  Future<void> saveEvents(List<EventModel> events) async {
    if (kIsWeb) {
      _memoryEvents.clear();
      for (var event in events) {
        _memoryEvents[event.id] = jsonEncode(event.toJson());
      }
    }
  }

  List<EventModel> getEvents() {
    if (kIsWeb) {
      return _memoryEvents.values
          .map((json) => EventModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> saveEvent(EventModel event) async {
    if (kIsWeb) {
      _memoryEvents[event.id] = jsonEncode(event.toJson());
    }
  }

  Future<void> deleteEvent(String id) async {
    if (kIsWeb) {
      _memoryEvents.remove(id);
    }
  }

  // Gifts
  Future<void> saveGifts(List<GiftModel> gifts) async {
    if (kIsWeb) {
      _memoryGifts.clear();
      for (var gift in gifts) {
        _memoryGifts[gift.id] = jsonEncode(gift.toJson());
      }
    }
  }

  List<GiftModel> getGifts() {
    if (kIsWeb) {
      return _memoryGifts.values
          .map((json) => GiftModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Gift Usages
  Future<void> saveGiftUsage(GiftUsageModel usage) async {
    if (kIsWeb) {
      _memoryGiftUsages[usage.id] = jsonEncode(usage.toJson());
    }
  }

  List<GiftUsageModel> getGiftUsages() {
    if (kIsWeb) {
      return _memoryGiftUsages.values
          .map((json) => GiftUsageModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
