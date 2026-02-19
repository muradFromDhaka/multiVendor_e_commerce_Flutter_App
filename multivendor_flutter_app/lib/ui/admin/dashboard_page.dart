import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/ui/admin/admin_home.dart';
import 'package:multivendor_flutter_app/ui/admin/brand/brand_list.dart';
import 'package:multivendor_flutter_app/ui/admin/category_page.dart';
import 'package:multivendor_flutter_app/ui/admin/common_widget.dart';
import 'package:multivendor_flutter_app/ui/admin/deals_page.dart';
import 'package:multivendor_flutter_app/ui/admin/inventory_page.dart';
import 'package:multivendor_flutter_app/ui/admin/orders_page.dart';
import 'package:multivendor_flutter_app/ui/admin/payouts_page.dart';
import 'package:multivendor_flutter_app/ui/admin/products_page.dart';
import 'package:multivendor_flutter_app/ui/admin/reports_page.dart';
import 'package:multivendor_flutter_app/ui/admin/roll_management_page.dart';
import 'package:multivendor_flutter_app/ui/admin/vendors_page.dart';
import 'package:multivendor_flutter_app/ui/auth/login_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminDashboardPage> {
  int selectedIndex = 0;
  bool isDarkMode = false;
  final _authService = AuthService();

  final pages = [
    AdminHomePage(),
    BrandList(),
    CategoryPage(),
    ProductsPage(),
    OrdersPage(),
    PayoutsPage(),
    InventoryPage(),
    DealsPage(),
    ReportsPage(),
    RoleManagementPage(),
    VendorsPage(),
  ];

  void onLogout() async {
    await _authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (Route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAdminAppBar(title: "Admin Panel"),
      drawer: CommonAdminDrawer(
        selectedIndex: selectedIndex,
        isDarkMode: isDarkMode,
        userName: "Super Admin",
        userEmail: "admin@email.com",
        onItemSelected: (index) {
          setState(() => selectedIndex = index);
        },
        onLogout: onLogout,
      ),
      body: pages[selectedIndex],
    );
  }
}
