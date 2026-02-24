import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/ui/admin/category/category_list.dart';
import 'package:multivendor_flutter_app/ui/auth/login_page.dart';
import 'package:multivendor_flutter_app/ui/public/public_product_list.dart';
import 'package:multivendor_flutter_app/ui/vendor/common_widget.dart';
import 'package:multivendor_flutter_app/ui/vendor/earnings_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/orders_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/payouts_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/reports_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/vendor_page/vendor_profile.dart';
import 'package:multivendor_flutter_app/ui/vendor/vendor_product/product_List.dart';

class VendorDashboardPage extends StatefulWidget {
  const VendorDashboardPage({super.key});

  @override
  State<VendorDashboardPage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<VendorDashboardPage> {
  int selectedIndex = 0;
  bool isDarkMode = false;
  final _authservice = AuthService();

  final pages = [
    VendorProductList(),
    CategoryList(),
    OrdersPage(),
    PayoutsPage(),
    EarningsPage(),
    ReportsPage(),
    VendorProfile(),
  ];

  void onLogout() async {
    await _authservice.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PublicProductListPage()),
      (Route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAdminAppBar(title: "Vendor Pannel"),
      drawer: CommonAdminDrawer(
        selectedIndex: selectedIndex,
        isDarkMode: isDarkMode,
        userName: "Vendor Dashborad",
        userEmail: "vendor@email.com",
        onItemSelected: (index) {
          setState(() => selectedIndex = index);
        },
        onLogout: onLogout,
      ),
      body: pages[selectedIndex],
    );
  }
}
