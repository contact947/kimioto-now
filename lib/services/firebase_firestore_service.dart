import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/article_model.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../models/gift_model.dart';
import '../models/gift_usage_model.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String articlesCollection = 'articles';
  static const String eventsCollection = 'events';
  static const String ticketsCollection = 'tickets';
  static const String giftsCollection = 'gifts';
  static const String giftUsagesCollection = 'gift_usages';

  // ========== Users ==========
  
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.id).set({
        'id': user.id,
        'name': user.name,
        'age': user.age,
        'gender': user.gender,
        'city': user.city,
        'prefecture': user.prefecture,
        'email': user.email,
        'role': user.role.toString().split('.').last,
        'createdAt': Timestamp.fromDate(user.createdAt),
      });
      debugPrint('✅ User saved to Firestore: ${user.id}');
    } catch (e) {
      debugPrint('❌ Error saving user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserModel(
          id: data['id'],
          name: data['name'],
          age: data['age'],
          gender: data['gender'],
          city: data['city'],
          prefecture: data['prefecture'],
          email: data['email'],
          role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == data['role'],
            orElse: () => UserRole.user,
          ),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user: $e');
      return null;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return UserModel(
          id: data['id'],
          name: data['name'],
          age: data['age'],
          gender: data['gender'],
          city: data['city'],
          prefecture: data['prefecture'],
          email: data['email'],
          role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == data['role'],
            orElse: () => UserRole.user,
          ),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user by email: $e');
      return null;
    }
  }

  // ========== Articles ==========
  
  Stream<List<ArticleModel>> getArticlesStream() {
    return _firestore
        .collection(articlesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ArticleModel(
          id: data['id'],
          title: data['title'],
          content: data['content'],
          category: data['category'],
          imageUrl: data['imageUrl'],
          authorId: data['authorId'],
          authorName: data['authorName'],
          city: data['city'],
          prefecture: data['prefecture'],
          viewCount: data['viewCount'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  Future<void> saveArticle(ArticleModel article) async {
    try {
      await _firestore.collection(articlesCollection).doc(article.id).set({
        'id': article.id,
        'title': article.title,
        'content': article.content,
        'category': article.category,
        'imageUrl': article.imageUrl,
        'authorId': article.authorId,
        'authorName': article.authorName,
        'city': article.city,
        'prefecture': article.prefecture,
        'viewCount': article.viewCount,
        'createdAt': Timestamp.fromDate(article.createdAt),
        'updatedAt': Timestamp.fromDate(article.updatedAt),
      });
      debugPrint('✅ Article saved to Firestore: ${article.id}');
    } catch (e) {
      debugPrint('❌ Error saving article: $e');
      rethrow;
    }
  }

  Future<void> deleteArticle(String articleId) async {
    try {
      await _firestore.collection(articlesCollection).doc(articleId).delete();
      debugPrint('✅ Article deleted from Firestore: $articleId');
    } catch (e) {
      debugPrint('❌ Error deleting article: $e');
      rethrow;
    }
  }

  // ========== Events ==========
  
  Stream<List<EventModel>> getEventsStream() {
    return _firestore
        .collection(eventsCollection)
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return EventModel(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          venue: data['venue'],
          city: data['city'],
          prefecture: data['prefecture'],
          eventDate: (data['eventDate'] as Timestamp).toDate(),
          ticketPrice: (data['ticketPrice'] as num).toDouble(),
          totalSeats: data['totalSeats'],
          availableSeats: data['availableSeats'],
          organizerId: data['organizerId'],
          organizerName: data['organizerName'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  Future<void> saveEvent(EventModel event) async {
    try {
      await _firestore.collection(eventsCollection).doc(event.id).set({
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'imageUrl': event.imageUrl,
        'venue': event.venue,
        'city': event.city,
        'prefecture': event.prefecture,
        'eventDate': Timestamp.fromDate(event.eventDate),
        'ticketPrice': event.ticketPrice,
        'totalSeats': event.totalSeats,
        'availableSeats': event.availableSeats,
        'organizerId': event.organizerId,
        'organizerName': event.organizerName,
        'createdAt': Timestamp.fromDate(event.createdAt),
      });
      debugPrint('✅ Event saved to Firestore: ${event.id}');
    } catch (e) {
      debugPrint('❌ Error saving event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(eventsCollection).doc(eventId).delete();
      debugPrint('✅ Event deleted from Firestore: $eventId');
    } catch (e) {
      debugPrint('❌ Error deleting event: $e');
      rethrow;
    }
  }

  // ========== Tickets ==========
  
  Stream<List<TicketModel>> getTicketsStream() {
    return _firestore
        .collection(ticketsCollection)
        .orderBy('purchasedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TicketModel(
          id: data['id'],
          eventId: data['eventId'],
          eventTitle: data['eventTitle'],
          userId: data['userId'],
          userName: data['userName'],
          qrCode: data['qrCode'],
          isUsed: data['isUsed'],
          purchasedAt: (data['purchasedAt'] as Timestamp).toDate(),
          usedAt: data['usedAt'] != null 
              ? (data['usedAt'] as Timestamp).toDate() 
              : null,
        );
      }).toList();
    });
  }

  Future<void> saveTicket(TicketModel ticket) async {
    try {
      await _firestore.collection(ticketsCollection).doc(ticket.id).set({
        'id': ticket.id,
        'eventId': ticket.eventId,
        'eventTitle': ticket.eventTitle,
        'userId': ticket.userId,
        'userName': ticket.userName,
        'qrCode': ticket.qrCode,
        'isUsed': ticket.isUsed,
        'purchasedAt': Timestamp.fromDate(ticket.purchasedAt),
        'usedAt': ticket.usedAt != null 
            ? Timestamp.fromDate(ticket.usedAt!) 
            : null,
      });
      debugPrint('✅ Ticket saved to Firestore: ${ticket.id}');
    } catch (e) {
      debugPrint('❌ Error saving ticket: $e');
      rethrow;
    }
  }

  // ========== Gifts ==========
  
  Stream<List<GiftModel>> getGiftsStream() {
    return _firestore
        .collection(giftsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return GiftModel(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          storeId: data['storeId'],
          storeName: data['storeName'],
          city: data['city'],
          prefecture: data['prefecture'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          maxUsagePerUser: data['maxUsagePerUser'],
          expiryDate: (data['expiryDate'] as Timestamp).toDate(),
          minAge: data['minAge'],
          maxAge: data['maxAge'],
          targetSchools: data['targetSchools'] != null 
              ? List<String>.from(data['targetSchools']) 
              : null,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  Future<void> saveGift(GiftModel gift) async {
    try {
      await _firestore.collection(giftsCollection).doc(gift.id).set({
        'id': gift.id,
        'title': gift.title,
        'description': gift.description,
        'imageUrl': gift.imageUrl,
        'storeId': gift.storeId,
        'storeName': gift.storeName,
        'city': gift.city,
        'prefecture': gift.prefecture,
        'latitude': gift.latitude,
        'longitude': gift.longitude,
        'maxUsagePerUser': gift.maxUsagePerUser,
        'expiryDate': gift.expiryDate != null ? Timestamp.fromDate(gift.expiryDate!) : null,
        'minAge': gift.minAge,
        'maxAge': gift.maxAge,
        'targetSchools': gift.targetSchools,
        'createdAt': Timestamp.fromDate(gift.createdAt),
      });
      debugPrint('✅ Gift saved to Firestore: ${gift.id}');
    } catch (e) {
      debugPrint('❌ Error saving gift: $e');
      rethrow;
    }
  }

  // ========== Gift Usages ==========
  
  Stream<List<GiftUsageModel>> getGiftUsagesStream() {
    return _firestore
        .collection(giftUsagesCollection)
        .orderBy('usedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return GiftUsageModel(
          id: data['id'],
          giftId: data['giftId'],
          userId: data['userId'],
          usedAt: (data['usedAt'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  Future<void> saveGiftUsage(GiftUsageModel usage) async {
    try {
      await _firestore.collection(giftUsagesCollection).doc(usage.id).set({
        'id': usage.id,
        'giftId': usage.giftId,
        'userId': usage.userId,
        'usedAt': Timestamp.fromDate(usage.usedAt),
      });
      debugPrint('✅ Gift usage saved to Firestore: ${usage.id}');
    } catch (e) {
      debugPrint('❌ Error saving gift usage: $e');
      rethrow;
    }
  }
}
