import 'package:flutter/material.dart';

void main() => runApp(const ExpenseManagerApp());

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _primary = Color(0xFF1565C0);
  static const Color _titleColor = Color(0xFF0B1B3A);
  static const Color _subtitleColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 5),
              const WalletLogo(),
              const SizedBox(height: 24),
              const Text(
                'Expense Manager',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _titleColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: _subtitleColor,
                ),
              ),
              const Spacer(flex: 6),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // TODO: chuyển sang màn hình tiếp theo ở các buổi sau
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bắt đầu!')),
                    );
                  },
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo ví: tờ tiền xanh lá phía sau, thân ví xanh dương, khóa ví bên phải.
class WalletLogo extends StatelessWidget {
  const WalletLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 90,
      child: Stack(
        children: [
          // Tờ tiền xanh đậm phía sau
          Positioned(
            left: 0,
            top: 8,
            child: Container(
              width: 16,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(6)),
              ),
            ),
          ),
          // Tờ tiền xanh nhạt
          Positioned(
            left: 12,
            top: 0,
            child: Container(
              width: 62,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF81C784),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
          ),
          // Thân ví
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          // Khóa ví
          Positioned(
            right: 0,
            bottom: 16,
            child: Container(
              width: 40,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
