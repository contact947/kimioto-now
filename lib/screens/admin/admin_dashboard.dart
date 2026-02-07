import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/user_model.dart';
import 'article_management_screen.dart';
import 'event_management_screen.dart';
import 'ticket_scanner_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    // アクセスガード (Admin は自動的に Planner 権限も持つ)
    final hasAccess = user != null && (user.role == UserRole.admin || user.role == UserRole.planner);
    
    if (!hasAccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'アクセス権限がありません',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '管理画面にアクセスするには管理者権限が必要です',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      );
    }

    // メニューアイテム生成
    final menuItems = _getMenuItems(user.role);
    final currentScreen = menuItems[_selectedIndex]['screen'] as Widget;

    return Scaffold(
      body: Row(
        children: [
          // サイドバー
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // ヘッダー
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '管理画面',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.role == UserRole.admin ? '管理者' : 'プランナー',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // メニュー
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      final isSelected = _selectedIndex == index;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.blue.shade50,
                        leading: Icon(
                          item['icon'] as IconData,
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.grey.shade600,
                        ),
                        title: Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? Colors.blue.shade700
                                : Colors.grey.shade800,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
                // フッター
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            user.name[0],
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('メイン画面に戻る'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // メインコンテンツ
          Expanded(
            child: currentScreen,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMenuItems(UserRole role) {
    final items = <Map<String, dynamic>>[];

    // 管理者のみ (Admin は自動的に全権限を持つ)
    if (role == UserRole.admin) {
      items.add({
        'title': '記事管理',
        'icon': Icons.article,
        'screen': const ArticleManagementScreen(),
      });
    }

    // 管理者とプランナー共通 (Admin は Planner 権限も含む)
    if (role == UserRole.admin || role == UserRole.planner) {
      items.addAll([
        {
          'title': 'イベント管理',
          'icon': Icons.event,
          'screen': const EventManagementScreen(),
        },
        {
          'title': 'チケットスキャン',
          'icon': Icons.qr_code_scanner,
          'screen': const TicketScannerScreen(),
        },
      ]);
    }

    return items;
  }
}
