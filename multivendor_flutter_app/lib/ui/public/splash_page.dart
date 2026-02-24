// import 'package:flutter/material.dart';
// import 'package:multivendor_flutter_app/services/auth_service.dart';
// import 'package:multivendor_flutter_app/ui/admin/dashboard_page.dart';
// import 'package:multivendor_flutter_app/ui/auth/login_page.dart';
// import 'package:multivendor_flutter_app/ui/public/home_page.dart';
// import 'package:multivendor_flutter_app/ui/public/public_product_list.dart';
// import 'package:multivendor_flutter_app/ui/user/user_home_page.dart';
// import 'package:multivendor_flutter_app/ui/user/user_product_list.dart';
// import 'package:multivendor_flutter_app/ui/vendor/dashboard_page.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   final AuthService _authService = AuthService();

//   @override
//   void initState() {
//     super.initState();
//     _startSplash();
//   }

//   void _startSplash() async {
//     // Splash delay
//     await Future.delayed(const Duration(seconds: 3));

//     final token = await _authService.getToken();

//     if (!mounted) return;

//     if (token != null && token.isNotEmpty) {
//       // Navigator.pushReplacement(
//       //   context,
//       //   MaterialPageRoute(builder: (_) => HomePage()),
//       // );

//       if (await _authService.hasRole('ROLE_ADMIN') ||
//           await _authService.hasRole('ROLE_MODERATOR')) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
//         );
//       } else if (await _authService.hasRole('ROLE_VENDOR')) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const VendorDashboardPage()),
//         );
//       } else if (await _authService.hasRole('ROLE_USER')) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const UserHomePage()),
//         );
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("No role assigned!")));
//       }
//     } else {
//       Navigator.pushReplacement(
//         context,
//         // MaterialPageRoute(builder: (_) => const LoginPage()),
//         MaterialPageRoute(builder: (_) => PublicProductListPage()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // change if needed
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // App Logo
//             Image.asset('assets/w7.png', width: 120, height: 120),

//             const SizedBox(height: 20),

//             // Loader
//             const CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/ui/admin/dashboard_page.dart';
import 'package:multivendor_flutter_app/ui/auth/login_page.dart';
import 'package:multivendor_flutter_app/ui/public/public_product_list.dart';
import 'package:multivendor_flutter_app/ui/user/user_home_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  void _startSplash() async {
    // Splash delay
    await Future.delayed(const Duration(seconds: 3));

    final token = await _authService.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // একবারে role check করে variable এ রাখা
      final isAdmin = await _authService.hasRole('ROLE_ADMIN');
      final isModerator = await _authService.hasRole('ROLE_MODERATOR');
      final isVendor = await _authService.hasRole('ROLE_VENDOR');
      final isUser = await _authService.hasRole('ROLE_USER');

      if (isAdmin || isModerator) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      } else if (isVendor) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VendorDashboardPage()),
        );
      } else if (isUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserHomePage()),
        );
      } else {
        // কোন role assign করা নেই
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No role assigned!")));
      }
    } else {
      // token নেই → public view
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PublicProductListPage()),
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
