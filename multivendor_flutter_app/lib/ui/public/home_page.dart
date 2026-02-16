import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/ui/admin/dashboard_page.dart';
import 'package:multivendor_flutter_app/ui/auth/login_page.dart';
import 'package:multivendor_flutter_app/ui/user/home_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/dashboard_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // final _authService = AuthService();
  // void _isLogin() async {
  //   bool tr = await _authService.isLoggedIn();
  //   bool checkRoll = await _authService.hasRole("ROLE_USER");
  //   final user = await _authService.getCurrentUser();

  //   print("isLogin: $tr");
  //   print("hasRoll: $checkRoll");
  //   print("User: $user");
  // }

  @override
  Widget build(BuildContext context) {
    final AuthService _authservice = AuthService();
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                if (await _authservice.hasRole('ROLE_ADMIN') ||
                    await _authservice.hasRole('ROLE_MODERATOR')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboardPage(),
                    ),
                  );
                } else if (await _authservice.hasRole('ROLE_VENDOR')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VendorDashboardPage(),
                    ),
                  );
                } else if (await _authservice.hasRole('ROLE_USER')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserHomePage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No role assigned!")),
                  );
                }
              },
              child: const Text("Go to Dashboard"),
            ),

            const SizedBox(height: 30),

            TextButton(
              onPressed: () async {
                try {
                  await _authservice.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false,
                  );
                } catch (e) {
                  print("Logout error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Logout failed!")),
                  );
                }
              },
              child: const Text("Logout"),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
