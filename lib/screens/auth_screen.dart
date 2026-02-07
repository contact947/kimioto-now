import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import 'main_screen.dart';
import 'package:uuid/uuid.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _prefectureController = TextEditingController();
  
  String _gender = '男性';
  bool _isLogin = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _prefectureController.dispose();
    super.dispose();
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AppProvider>(context, listen: false);

    try {
      if (_isLogin) {
        await provider.login(_emailController.text, 'password');
      } else {
        final user = UserModel(
          id: const Uuid().v4(),
          name: _nameController.text,
          age: int.parse(_ageController.text),
          gender: _gender,
          city: _cityController.text,
          prefecture: _prefectureController.text,
          email: _emailController.text,
          role: UserRole.user,
          createdAt: DateTime.now(),
        );
        await provider.register(user);
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.event_available,
                    size: 40,
                    color: Colors.blue.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Local Beat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _isLogin ? 'ログイン' : '新規登録',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '名前',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? '名前を入力してください' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          labelText: '年齢',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty ?? true ? '年齢を入力してください' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          labelText: '性別',
                          border: OutlineInputBorder(),
                        ),
                        items: ['男性', '女性', 'その他'].map((g) {
                          return DropdownMenuItem(value: g, child: Text(g));
                        }).toList(),
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _prefectureController,
                        decoration: const InputDecoration(
                          labelText: '都道府県',
                          border: OutlineInputBorder(),
                          hintText: '例: 東京都',
                        ),
                        validator: (v) => v?.isEmpty ?? true ? '都道府県を入力してください' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: '市区町村',
                          border: OutlineInputBorder(),
                          hintText: '例: 渋谷区',
                        ),
                        validator: (v) => v?.isEmpty ?? true ? '市区町村を入力してください' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'メールアドレス',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v?.isEmpty ?? true ? 'メールアドレスを入力してください' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isLogin ? 'ログイン' : '登録する',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin ? '新規登録はこちら' : 'ログインはこちら',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'スキップ',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
