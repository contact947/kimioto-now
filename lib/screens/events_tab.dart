import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';
import 'package:intl/intl.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  @override
  void initState() {
    super.initState();
    // デバッグ用：画面表示時にデータ状態をログ出力
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugPrintEventData();
    });
  }

  void _debugPrintEventData() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final user = provider.currentUser;
    
    debugPrint('=== EventsTab デバッグ情報 ===');
    debugPrint('現在のユーザー: ${user?.name ?? "未ログイン"}');
    debugPrint('ユーザーの地域: ${user?.city ?? "未設定"}');
    debugPrint('全イベント数: ${provider.events.length}');
    
    if (provider.events.isNotEmpty) {
      debugPrint('--- 全イベントリスト ---');
      for (var event in provider.events) {
        debugPrint('  - ${event.title} (${event.city}, ${event.eventDate})');
      }
    }
    
    if (user != null) {
      final localEvents = provider.getEventsByCity(user.city);
      debugPrint('地域のイベント数: ${localEvents.length}');
      if (localEvents.isNotEmpty) {
        debugPrint('--- 地域のイベント ---');
        for (var event in localEvents) {
          debugPrint('  - ${event.title}');
        }
      }
    }
    
    final allEvents = provider.getUpcomingEvents();
    debugPrint('全国のイベント数（未来のみ）: ${allEvents.length}');
    if (allEvents.isNotEmpty) {
      debugPrint('--- 全国のイベント ---');
      for (var event in allEvents) {
        debugPrint('  - ${event.title}');
      }
    }
    debugPrint('============================');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    // 地域のイベント
    final List<EventModel> localEvents = user != null
        ? provider.getEventsByCity(user.city)
        : <EventModel>[];

    // 全国のイベント
    final List<EventModel> allEvents = provider.getUpcomingEvents();

    // デバッグ情報を画面下部に表示（開発中のみ）
    final bool showDebugInfo = true; // 本番環境では false にする

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'イベント',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.blue.shade400,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.blue.shade400,
            tabs: const [
              Tab(text: '地域のイベント'),
              Tab(text: '全国のイベント'),
            ],
          ),
        ),
        body: Column(
          children: [
            // デバッグ情報バー（開発中のみ表示）
            if (showDebugInfo)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.amber.shade100,
                child: Text(
                  'デバッグ: 地域=${localEvents.length}件, 全国=${allEvents.length}件, 全データ=${provider.events.length}件',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            // タブビュー
            Expanded(
              child: TabBarView(
                children: [
                  _EventListTab(
                    events: localEvents,
                    emptyMessage: user != null
                        ? '${user.city}にはまだイベントがありません'
                        : 'ログインして地域のイベントを表示',
                  ),
                  _EventListTab(
                    events: allEvents,
                    emptyMessage: '現在予定されているイベントがありません',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventListTab extends StatelessWidget {
  final List<EventModel> events;
  final String emptyMessage;

  const _EventListTab({
    required this.events,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    // データが空の場合の表示
    if (events.isEmpty) {
      return Container(
        color: Colors.grey.shade50, // 背景色を明示的に指定
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'イベントが追加されるまでお待ちください',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // データがある場合のリスト表示
    return Container(
      color: Colors.grey.shade50, // 背景色を明示的に指定
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return _EventCard(event: events[index]);
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd (E) HH:mm', 'ja_JP');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // イベント画像
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                event.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 160,
                    color: Colors.grey.shade100,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('画像読み込みエラー: $error');
                  return Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, 
                          size: 64, 
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '画像を読み込めませんでした',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // イベント情報
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイトル
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // 場所
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 日時
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(event.eventDate),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 価格と空席情報
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¥${event.ticketPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: event.availableSeats > 0 
                              ? Colors.green.shade50 
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.availableSeats > 0 
                              ? '残り${event.availableSeats}席'
                              : '満席',
                          style: TextStyle(
                            fontSize: 12,
                            color: event.availableSeats > 0
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
