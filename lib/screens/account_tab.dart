import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import 'auth_screen.dart';
import 'admin/admin_dashboard.dart';
import 'admin/article_management_screen.dart';
import 'admin/event_management_screen.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'アカウント',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: user == null ? _buildGuestView(context) : _buildUserView(context, user, provider),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              'ログインしていません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'アカウントを作成してイベントやギフトを楽しもう',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ログイン / 新規登録',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserView(BuildContext context, UserModel user, AppProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRoleBadgeColor(user.role),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoleIcon(user.role),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getRoleName(user.role),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ユーザー情報
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  title: '年齢',
                  value: '${user.age}歳',
                  icon: Icons.cake_outlined,
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                _buildInfoTile(
                  title: '地域',
                  value: '${user.prefecture} ${user.city}',
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 管理者専用メニュー
          if (user.role == UserRole.admin || user.role == UserRole.planner) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '管理メニュー',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // スマホ版: 個別の管理画面へのリンク
            if (MediaQuery.of(context).size.width < 600) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.article,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    '記事管理',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArticleManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // イベント管理 (admin & planner共通)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.event,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'イベント管理',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EventManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // PC版: 管理画面ダッシュボードへのリンク
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.dashboard,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    '管理ダッシュボード',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboard(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],

          // ログアウトボタン
          Container(
            margin: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  provider.logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ログアウト',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleBadgeColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red.shade400;
      case UserRole.planner:
        return Colors.orange.shade400;
      case UserRole.user:
        return Colors.green.shade400;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.planner:
        return Icons.event_note;
      case UserRole.user:
        return Icons.person;
    }
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '管理者';
      case UserRole.planner:
        return 'プランナー';
      case UserRole.user:
        return 'ユーザー';
    }
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
