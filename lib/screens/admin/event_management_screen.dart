import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/event_model.dart';
import 'package:intl/intl.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final events = provider.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント管理'),
        elevation: 0,
      ),
      body: events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'イベントがありません',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '右下の＋ボタンから追加できます',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventCard(context, event, provider);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(context, provider, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event, AppProvider provider) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ja_JP');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // イベント画像
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              event.imageUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 150,
                color: Colors.grey.shade200,
                child: const Icon(Icons.event, size: 48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(event.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      event.organizer,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.map, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${event.prefecture} ${event.city}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEventDialog(context, provider, event),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('編集'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context, provider, event),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('削除'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDialog(BuildContext context, AppProvider provider, EventModel? event) {
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    final organizerController = TextEditingController(text: event?.organizer ?? '');
    final imageUrlController = TextEditingController(text: event?.imageUrl ?? '');
    final cityController = TextEditingController(text: event?.city ?? '');
    final prefectureController = TextEditingController(text: event?.prefecture ?? '');
    
    DateTime selectedDate = event?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(event == null ? '新規イベント作成' : 'イベント編集'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'タイトル',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '詳細',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: '場所',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: organizerController,
                  decoration: const InputDecoration(
                    labelText: '主催者',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: '画像URL',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/image.jpg',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: prefectureController,
                  decoration: const InputDecoration(
                    labelText: '都道府県',
                    border: OutlineInputBorder(),
                    hintText: '東京都',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: '市区町村',
                    border: OutlineInputBorder(),
                    hintText: '渋谷区',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('開催日時'),
                  subtitle: Text(
                    DateFormat('yyyy/MM/dd HH:mm', 'ja_JP').format(selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    locationController.text.isEmpty ||
                    organizerController.text.isEmpty ||
                    imageUrlController.text.isEmpty ||
                    cityController.text.isEmpty ||
                    prefectureController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('全ての項目を入力してください')),
                  );
                  return;
                }

                final newEvent = EventModel(
                  id: event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  date: selectedDate,
                  location: locationController.text,
                  organizer: organizerController.text,
                  imageUrl: imageUrlController.text,
                  city: cityController.text,
                  prefecture: prefectureController.text,
                );

                if (event == null) {
                  provider.addEvent(newEvent);
                } else {
                  provider.updateEvent(newEvent);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(event == null ? 'イベントを作成しました' : 'イベントを更新しました'),
                  ),
                );
              },
              child: Text(event == null ? '作成' : '更新'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppProvider provider, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${event.title}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteEvent(event.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('イベントを削除しました')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
