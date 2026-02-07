import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/article_model.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ユーザー取得
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting user: $e');
      }
      return null;
    }
  }

  // ユーザー保存
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  // 記事取得
  Stream<List<ArticleModel>> getArticles() {
    return _firestore
        .collection('articles')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ArticleModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // 記事追加
  Future<void> addArticle(ArticleModel article) async {
    await _firestore.collection('articles').doc(article.id).set(article.toJson());
  }

  // 記事更新
  Future<void> updateArticle(ArticleModel article) async {
    await _firestore.collection('articles').doc(article.id).update(article.toJson());
  }

  // 記事削除
  Future<void> deleteArticle(String id) async {
    await _firestore.collection('articles').doc(id).delete();
  }

  // イベント取得
  Stream<List<EventModel>> getEvents() {
    return _firestore
        .collection('events')
        .orderBy('event_date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // イベント追加
  Future<void> addEvent(EventModel event) async {
    await _firestore.collection('events').doc(event.id).set(event.toJson());
  }

  // イベント更新
  Future<void> updateEvent(EventModel event) async {
    await _firestore.collection('events').doc(event.id).update(event.toJson());
  }

  // イベント削除
  Future<void> deleteEvent(String id) async {
    await _firestore.collection('events').doc(id).delete();
  }

  // チケット取得
  Future<TicketModel?> getTicket(String qrCode) async {
    try {
      final query = await _firestore
          .collection('tickets')
          .where('qr_code', isEqualTo: qrCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return TicketModel.fromJson({...doc.data(), 'id': doc.id});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting ticket: $e');
      }
      return null;
    }
  }

  // チケット使用済みにする
  Future<void> markTicketAsUsed(String ticketId) async {
    await _firestore.collection('tickets').doc(ticketId).update({
      'is_used': true,
      'used_at': DateTime.now().toIso8601String(),
    });
  }

  // カテゴリ取得
  Future<List<String>> getCategories(String type) async {
    try {
      final doc = await _firestore.collection('settings').doc('categories').get();
      if (!doc.exists) return [];
      final data = doc.data();
      return List<String>.from(data?[type] ?? []);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting categories: $e');
      }
      return [];
    }
  }

  // カテゴリ追加
  Future<void> addCategory(String type, String category) async {
    final docRef = _firestore.collection('settings').doc('categories');
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        type: [category]
      });
    } else {
      final data = doc.data() ?? {};
      final categories = List<String>.from(data[type] ?? []);
      if (!categories.contains(category)) {
        categories.add(category);
        await docRef.update({type: categories});
      }
    }
  }

  // 画像アップロード
  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
