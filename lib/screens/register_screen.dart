import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user_model.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _prefectureController = TextEditingController();
  
  String _selectedGender = '男性';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _prefectureController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        city: _cityController.text.trim(),
        prefecture: _prefectureController.text.trim(),
        email: _emailController.text.trim(),
        role: UserRole.user,
        createdAt: DateTime.now(),
      );

      await provider.register(user);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登録に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // タイトル
                const Text(
                  'アカウント作成',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'あなたの情報を入力してください',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // 名前入力
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'お名前',
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: '山田 太郎',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'お名前を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // メールアドレス入力
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'example@email.com',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスを入力してください';
                    }
                    if (!value.contains('@')) {
                      return '有効なメールアドレスを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // パスワード入力
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'パスワード',
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: '6文字以上',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください';
                    }
                    if (value.length < 6) {
                      return 'パスワードは6文字以上で入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 年齢入力
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '年齢',
                    prefixIcon: Icon(Icons.cake_outlined),
                    hintText: '25',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '年齢を入力してください';
                    }
                    if (int.tryParse(value) == null) {
                      return '有効な年齢を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 性別選択
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: '性別',
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: '男性', child: Text('男性')),
                    DropdownMenuItem(value: '女性', child: Text('女性')),
                    DropdownMenuItem(value: 'その他', child: Text('その他')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // 都道府県入力
                TextFormField(
                  controller: _prefectureController,
                  decoration: const InputDecoration(
                    labelText: '都道府県',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: '東京都',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '都道府県を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 市区町村入力
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: '市区町村',
                    prefixIcon: Icon(Icons.location_city_outlined),
                    hintText: '渋谷区',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '市区町村を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // 登録ボタン
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '登録する',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
                const SizedBox(height: 16),
                
                // 利用規約
                Text(
                  '登録することで、利用規約とプライバシーポリシーに同意したものとみなされます',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
