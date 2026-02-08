import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/article_model.dart';
import 'article_detail_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    // 1. 全国のニュース (新着順、上限5件)
    final allNews = provider.articles
        .where((a) => a.category == 'イベント' || a.category == '店舗')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final limitedAllNews = allNews.take(5).toList();

    // 2. 地域のニュース (新着順、上限5件)
    final localArticles = user != null
        ? provider.getArticlesByCity(user.city)
        : <ArticleModel>[];
    final localNews = localArticles
        .where((a) => a.category == 'イベント' || a.category == '店舗')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final limitedLocalNews = localNews.take(5).toList();

    // 3. 地域のコラム (アクセス数順、上限10件)
    final localColumns = localArticles
        .where((a) => a.category == 'インタビュー' || a.category == 'コラム')
        .toList()
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    final limitedLocalColumns = localColumns.take(10).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ホーム',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${user.city}のニュース',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // データが全く無い場合の表示
            if (limitedAllNews.isEmpty && limitedLocalNews.isEmpty && limitedLocalColumns.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.celebration_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'データを読み込み中...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '少々お待ちください',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            
            // 1. 全国のニュース (カード表示、上限5件)
            if (limitedAllNews.isNotEmpty) ...[
              _SectionTitle(title: '全国のニュース'),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: limitedAllNews.length,
                  itemBuilder: (context, index) {
                    return _NewsCard(article: limitedAllNews[index]);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // 2. 地域のニュース (カード表示、上限5件)
            if (limitedLocalNews.isNotEmpty) ...[
              _SectionTitle(title: '地域のニュース'),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: limitedLocalNews.length,
                  itemBuilder: (context, index) {
                    return _NewsCard(article: limitedLocalNews[index]);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // 3. 地域のコラム (リスト表示、上限10件)
            if (limitedLocalColumns.isNotEmpty) ...[
              _SectionTitle(title: '地域のコラム'),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: limitedLocalColumns.length,
                itemBuilder: (context, index) {
                  return _ColumnListItem(article: limitedLocalColumns[index]);
                },
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final ArticleModel article;

  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                article.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image, size: 48, color: Colors.grey.shade400),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnListItem extends StatelessWidget {
  final ArticleModel article;

  const _ColumnListItem({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image, size: 32, color: Colors.grey.shade400),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      article.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${article.viewCount}回',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
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
