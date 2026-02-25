import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/ui/admin/brand/brand_list.dart';
import 'package:multivendor_flutter_app/ui/admin/category/category_list.dart';
import 'package:multivendor_flutter_app/ui/admin/common_widget.dart';
import 'package:multivendor_flutter_app/ui/admin/deals_page.dart';
import 'package:multivendor_flutter_app/ui/admin/inventory_page.dart';
import 'package:multivendor_flutter_app/ui/admin/orders_page.dart';
import 'package:multivendor_flutter_app/ui/admin/payout_page.dart';
import 'package:multivendor_flutter_app/ui/admin/product/product_List.dart';
import 'package:multivendor_flutter_app/ui/admin/reports_page.dart';
import 'package:multivendor_flutter_app/ui/admin/roll_management_page.dart';
import 'package:multivendor_flutter_app/ui/admin/vendors_page.dart';
import 'package:multivendor_flutter_app/ui/public/public_product_list.dart';

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
    ProductList(),
    BrandList(),
    CategoryList(),
    OrdersPage(),
    PayoutPage(),
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
      MaterialPageRoute(builder: (_) => const PublicProductListPage()),
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
