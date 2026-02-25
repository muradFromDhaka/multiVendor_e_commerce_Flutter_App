// import 'package:flutter/material.dart';
// import 'package:multivendor_flutter_app/services/auth_service.dart';
// import 'package:multivendor_flutter_app/ui/public/cart_page.dart';
// import 'package:multivendor_flutter_app/ui/public/public_product_list.dart';
// import 'package:multivendor_flutter_app/ui/user/checkout_page.dart';
// import 'package:multivendor_flutter_app/ui/user/common_widget.dart';
// import 'package:multivendor_flutter_app/ui/user/orders_page.dart';
// import 'package:multivendor_flutter_app/ui/user/payment_page.dart';
// import 'package:multivendor_flutter_app/ui/user/reviews_page.dart';
// import 'package:multivendor_flutter_app/ui/user/user_product_list.dart';
// import 'package:multivendor_flutter_app/ui/user/wishlist_page.dart';
// import 'package:multivendor_flutter_app/ui/vendor/vendor_page/vendor_form.dart';
// import 'package:multivendor_flutter_app/ui/vendor/vendor_page/vendor_profile.dart';

// class UserHomePage extends StatefulWidget {
//   const UserHomePage({super.key});

//   @override
//   State<UserHomePage> createState() => _AdminHomePageState();
// }

// class _AdminHomePageState extends State<UserHomePage> {
//   int selectedIndex = 0;
//   bool isDarkMode = false;
//   final _authservice = AuthService();

//   final pages = [
//     UserProductListPage(),
//     CartPage(),
//     CheckoutPage(),
//     OrdersPage(),
//     PaymentPage(),
//     ReviewsPage(),
//     WishlistPage(),
//     VendorForm(),
//     VendorProfile(),
//   ];

//   void onLogout() async {
//     await _authservice.logout();
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const PublicProductListPage()),
//       (Route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAdminAppBar(title: "e-commerce app"),
//       drawer: CommonAdminDrawer(
//         selectedIndex: selectedIndex,
//         isDarkMode: isDarkMode,
//         userName: "Register User",
//         userEmail: "user@email.com",
//         onItemSelected: (index) {
//           setState(() => selectedIndex = index);
//         },
//         onLogout: onLogout,
//       ),
//       body: pages[selectedIndex],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/ui/public/cart_page.dart';
import 'package:multivendor_flutter_app/ui/public/public_product_list.dart';
import 'package:multivendor_flutter_app/ui/user/common_widget.dart';
import 'package:multivendor_flutter_app/ui/user/orders_page.dart';
import 'package:multivendor_flutter_app/ui/user/payment_page.dart';
import 'package:multivendor_flutter_app/ui/user/reviews_page.dart';
import 'package:multivendor_flutter_app/ui/user/user_product_list.dart';
import 'package:multivendor_flutter_app/ui/user/wishlist_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/vendor_page/vendor_form.dart';
import 'package:multivendor_flutter_app/ui/vendor/vendor_page/vendor_profile.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int selectedIndex = 0;
  bool isDarkMode = false;

  final AuthService _authservice = AuthService();

  String? userName;
  String? userEmail;
  bool isUserLoading = true;

  final pages = [
    UserProductListPage(),
    CartPage(),
    OrdersPage(),
    PaymentPage(),
    ReviewsPage(),
    WishlistPage(),
    VendorForm(),
    VendorProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authservice.getCurrentUser();

    if (user != null) {
      setState(() {
        userName = user['userName'];
        userEmail = user['email'];
        isUserLoading = false;
      });
    } else {
      setState(() => isUserLoading = false);
    }
  }

  void onLogout() async {
    await _authservice.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PublicProductListPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAdminAppBar(title: "e-commerce app"),
      drawer: CommonAdminDrawer(
        selectedIndex: selectedIndex,
        isDarkMode: isDarkMode,
        userName: _buildUserName(),
        userEmail: _buildUserEmail(),
        onItemSelected: (index) {
          setState(() => selectedIndex = index);
        },
        onLogout: onLogout,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isUserLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return pages[selectedIndex];
  }

  String _buildUserName() {
    if (isUserLoading) return "Loading...";
    if (userName == null || userName!.isEmpty) return "User";
    return userName!;
  }

  String _buildUserEmail() {
    if (isUserLoading) return "";
    return userEmail ?? "";
  }
}
