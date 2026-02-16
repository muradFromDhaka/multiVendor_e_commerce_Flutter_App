import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/ui/auth/login_page.dart';
import 'package:multivendor_flutter_app/ui/public/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  void _startSplash() async {
    // Splash delay
    await Future.delayed(const Duration(seconds: 3));

    final token = await authService.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // change if needed
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Logo
            Image.asset('assets/w7.png', width: 120, height: 120),

            const SizedBox(height: 20),

            // Loader
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
