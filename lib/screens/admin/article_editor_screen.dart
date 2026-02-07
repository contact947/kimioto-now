import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../models/article_model.dart';
import '../../utils/japan_addresses.dart';

class ArticleEditorScreen extends StatefulWidget {
  final ArticleModel? article;

  const ArticleEditorScreen({super.key, this.article});

  @override
  State<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends State<ArticleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedPrefecture;
  String? _selectedCity;
  bool _isLoading = false;

  final List<String> _categories = ['店舗', 'イベント', 'インタビュー', 'コラム'];

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _titleController.text = widget.article!.title;
      _contentController.text = widget.article!.content;
      _imageUrlController.text = widget.article!.imageUrl;
      _selectedCategory = widget.article!.category;
      _selectedPrefecture = widget.article!.prefecture;
      _selectedCity = widget.article!.city;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
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
          widget.article == null ? '記事作成' : '記事編集',
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
                  'タイトル',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: '記事のタイトルを入力',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'タイトルを入力してください' : null,
                ),
                const SizedBox(height: 24),

                // カテゴリ
                const Text(
                  'カテゴリ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          hintText: 'カテゴリを選択',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: _categories.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        validator: (v) => v == null ? 'カテゴリを選択してください' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _addNewCategory,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('新規追加'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 地域
                const Text(
                  '地域',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
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
                            _selectedCity = null; // 市区町村をリセット
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

                // 本文
                const Text(
                  '本文',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: '記事の本文を入力',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 10,
                  validator: (v) => v?.isEmpty ?? true ? '本文を入力してください' : null,
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

  Future<void> _addNewCategory() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいカテゴリを追加'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'カテゴリ名を入力',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        if (!_categories.contains(result)) {
          _categories.add(result);
        }
        _selectedCategory = result;
      });
    }
    controller.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final user = provider.currentUser!;

      final article = ArticleModel(
        id: widget.article?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory!,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? 'https://picsum.photos/seed/${const Uuid().v4()}/400/300'
            : _imageUrlController.text.trim(),
        authorId: user.id,
        authorName: user.name,
        city: _selectedCity!,
        prefecture: _selectedPrefecture!,
        viewCount: widget.article?.viewCount ?? 0,
        createdAt: widget.article?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.article == null) {
        await provider.addArticle(article);
      } else {
        await provider.updateArticle(article);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.article == null ? '記事を作成しました' : '記事を更新しました',
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
