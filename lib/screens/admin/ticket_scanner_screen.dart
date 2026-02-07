import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/app_provider.dart';

class TicketScannerScreen extends StatefulWidget {
  const TicketScannerScreen({super.key});

  @override
  State<TicketScannerScreen> createState() => _TicketScannerScreenState();
}

class _TicketScannerScreenState extends State<TicketScannerScreen> {
  MobileScannerController? _cameraController;
  bool _isProcessing = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // カメラビュー
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),
          // オーバーレイ
          Column(
            children: [
              // ヘッダー
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          'チケットスキャン',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleFlash,
                        icon: const Icon(Icons.flash_on, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // スキャンエリア
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Spacer(),
              // 説明
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.black.withValues(alpha: 0.5),
                child: const Text(
                  'チケットのQRコードをスキャンしてください',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          // ローディング
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _toggleFlash() async {
    await _cameraController?.toggleTorch();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code == _lastScannedCode) return;

    setState(() {
      _isProcessing = true;
      _lastScannedCode = code;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final tickets = provider.tickets;
      
      // チケット検索
      final ticket = tickets.where((t) => t.qrCode == code).firstOrNull;

      if (ticket == null) {
        await _showResult(
          icon: Icons.error_outline,
          iconColor: Colors.red.shade400,
          title: '無効なチケット',
          message: 'このQRコードは登録されていません',
        );
      } else if (ticket.isUsed) {
        await _showResult(
          icon: Icons.cancel_outlined,
          iconColor: Colors.orange.shade400,
          title: '使用済みチケット',
          message: 'このチケットは既に使用されています\n\n使用日時: ${ticket.usedAt != null ? _formatDateTime(ticket.usedAt!) : "不明"}',
        );
      } else {
        // TODO: チケットを使用済みにする処理
        await _showResult(
          icon: Icons.check_circle_outline,
          iconColor: Colors.green.shade400,
          title: '有効なチケット',
          message: 'イベント: ${ticket.eventTitle}\n参加者: ${ticket.userName}',
          isValid: true,
        );
      }
    } catch (e) {
      await _showResult(
        icon: Icons.error_outline,
        iconColor: Colors.red.shade400,
        title: 'エラー',
        message: 'チケットの確認中にエラーが発生しました',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        // 3秒後にリセット
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _lastScannedCode = null;
          });
        }
      }
    }
  }

  Future<void> _showResult({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    bool isValid = false,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 80, color: iconColor),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('閉じる'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}/${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
