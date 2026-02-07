import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/article_model.dart';
import 'package:uuid/uuid.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '管理者画面',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.purple.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '管理者権限',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      Text(
                        '記事の投稿・編集が可能です',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                '記事一覧',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showArticleEditor(context, provider),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新規作成'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...provider.articles.map((article) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 24),
                    ),
                  ),
                ),
                title: Text(
                  article.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${article.category} • ${article.city}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showArticleEditor(
                        context,
                        provider,
                        article: article,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: Colors.red.shade400),
                      onPressed: () => _deleteArticle(context, provider, article.id),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showArticleEditor(
    BuildContext context,
    AppProvider provider, {
    ArticleModel? article,
  }) async {
    final titleController = TextEditingController(text: article?.title ?? '');
    final contentController = TextEditingController(text: article?.content ?? '');
    final imageUrlController = TextEditingController(text: article?.imageUrl ?? '');
    final cityController = TextEditingController(text: article?.city ?? '渋谷区');
    final prefectureController = TextEditingController(text: article?.prefecture ?? '東京都');
    
    String category = article?.category ?? '店舗';

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  article == null ? '新規記事作成' : '記事編集',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'タイトル',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '本文',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'カテゴリ',
                      border: OutlineInputBorder(),
                    ),
                    items: ['店舗', 'イベント', 'インタビュー', 'コラム'].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (v) => setState(() => category = v!),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: prefectureController,
                        decoration: const InputDecoration(
                          labelText: '都道府県',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: '市区町村',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: '画像URL',
                    border: OutlineInputBorder(),
                    hintText: 'https://...',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('キャンセル'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isEmpty ||
                            contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('タイトルと本文は必須です'),
                            ),
                          );
                          return;
                        }

                        final newArticle = ArticleModel(
                          id: article?.id ?? const Uuid().v4(),
                          title: titleController.text,
                          content: contentController.text,
                          category: category,
                          imageUrl: imageUrlController.text.isNotEmpty
                              ? imageUrlController.text
                              : 'https://picsum.photos/seed/${const Uuid().v4()}/400/300',
                          authorId: provider.currentUser!.id,
                          authorName: provider.currentUser!.name,
                          city: cityController.text,
                          prefecture: prefectureController.text,
                          viewCount: article?.viewCount ?? 0,
                          createdAt: article?.createdAt ?? DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        if (article == null) {
                          provider.addArticle(newArticle);
                        } else {
                          provider.updateArticle(newArticle);
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              article == null ? '記事を作成しました' : '記事を更新しました',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(article == null ? '作成' : '更新'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    titleController.dispose();
    contentController.dispose();
    imageUrlController.dispose();
    cityController.dispose();
    prefectureController.dispose();
  }

  Future<void> _deleteArticle(
    BuildContext context,
    AppProvider provider,
    String articleId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記事を削除'),
        content: const Text('この記事を削除しますか?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deleteArticle(articleId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('記事を削除しました')),
        );
      }
    }
  }
}
