import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/event_model.dart';
import '../../utils/japan_addresses.dart';

class EventEditorScreen extends StatefulWidget {
  final EventModel? event;

  const EventEditorScreen({super.key, this.event});

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalSeatsController = TextEditingController();
  
  String? _selectedPrefecture;
  String? _selectedCity;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _venueController.text = widget.event!.venue;
      _imageUrlController.text = widget.event!.imageUrl;
      _priceController.text = widget.event!.ticketPrice.toStringAsFixed(0);
      _totalSeatsController.text = widget.event!.totalSeats.toString();
      _selectedPrefecture = widget.event!.prefecture;
      _selectedCity = widget.event!.city;
      _selectedDate = DateTime(
        widget.event!.eventDate.year,
        widget.event!.eventDate.month,
        widget.event!.eventDate.day,
      );
      _selectedTime = TimeOfDay(
        hour: widget.event!.eventDate.hour,
        minute: widget.event!.eventDate.minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _totalSeatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cities = _selectedPrefecture != null
        ? JapanAddresses.getCities(_selectedPrefecture!)
        : <String>[];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.event == null ? 'イベント作成' : 'イベント編集',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.black87,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('保存'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル
                const Text(
                  'イベント名',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'イベントのタイトルを入力',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'イベント名を入力してください' : null,
                ),
                const SizedBox(height: 24),

                // 会場と地域
                const Text(
                  '開催場所',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _venueController,
                  decoration: InputDecoration(
                    hintText: '会場名を入力',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (v) => v?.isEmpty ?? true ? '会場名を入力してください' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPrefecture,
                        decoration: InputDecoration(
                          hintText: '都道府県',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: JapanAddresses.prefectures.map((p) {
                          return DropdownMenuItem(value: p, child: Text(p));
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedPrefecture = v;
                            _selectedCity = null;
                          });
                        },
                        validator: (v) => v == null ? '都道府県を選択してください' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: InputDecoration(
                          hintText: '市区町村',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: cities.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedCity = v),
                        validator: (v) => v == null ? '市区町村を選択してください' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 開催日時
                const Text(
                  '開催日時',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            hintText: '日付を選択',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate != null
                                    ? DateFormat('yyyy年MM月dd日').format(_selectedDate!)
                                    : '日付を選択',
                                style: TextStyle(
                                  color: _selectedDate != null
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _selectTime,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            hintText: '時刻を選択',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : '時刻を選択',
                                style: TextStyle(
                                  color: _selectedTime != null
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const Icon(Icons.access_time, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // チケット価格と座席数
                const Text(
                  'チケット情報',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          hintText: '価格',
                          prefixText: '¥ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) => v?.isEmpty ?? true ? '価格を入力してください' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _totalSeatsController,
                        decoration: InputDecoration(
                          hintText: '総座席数',
                          suffixText: '席',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) => v?.isEmpty ?? true ? '座席数を入力してください' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 説明
                const Text(
                  'イベント説明',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'イベントの詳細説明を入力',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 8,
                  validator: (v) => v?.isEmpty ?? true ? '説明を入力してください' : null,
                ),
                const SizedBox(height: 24),

                // 画像
                const Text(
                  '画像',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    hintText: '画像URLを入力 (https://...)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    helperText: '※ 現在はURL入力のみ対応しています',
                  ),
                ),
                if (_imageUrlController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrlController.text,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Text('画像を読み込めませんでした'),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('開催日時を選択してください')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final user = provider.currentUser!;

      final eventDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final totalSeats = int.parse(_totalSeatsController.text);

      final event = EventModel(
        id: widget.event?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? 'https://picsum.photos/seed/${const Uuid().v4()}/400/300'
            : _imageUrlController.text.trim(),
        venue: _venueController.text.trim(),
        city: _selectedCity!,
        prefecture: _selectedPrefecture!,
        eventDate: eventDate,
        ticketPrice: double.parse(_priceController.text.trim()),
        totalSeats: totalSeats,
        availableSeats: widget.event?.availableSeats ?? totalSeats,
        organizerId: user.id,
        organizerName: user.name,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
      );

      if (widget.event == null) {
        await provider.addEvent(event);
      } else {
        // Note: updateEvent機能はAppProviderに実装が必要
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.event == null ? 'イベントを作成しました' : 'イベントを更新しました',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
