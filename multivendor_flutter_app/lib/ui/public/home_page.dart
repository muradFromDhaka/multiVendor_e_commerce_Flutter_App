import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/ui/admin/dashboard_page.dart';
import 'package:multivendor_flutter_app/ui/auth/login_page.dart';
import 'package:multivendor_flutter_app/ui/user/home_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/dashboard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authservice = AuthService();
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Column(
        children: [
          const SizedBox(height: 40),

          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                );
              },
              child: const Text("Go to Admin Dashboard"),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VendorDashboardPage(),
                  ),
                );
              },
              child: const Text("Go to Vendor Dashboard"),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserHomePage()),
                );
              },
              child: const Text("Go to User Home Page"),
            ),
          ),

          const SizedBox(height: 30),

          TextButton(
            onPressed: () async {
              await authservice.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
