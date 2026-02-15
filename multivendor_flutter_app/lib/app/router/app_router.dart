import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/app/router/route_names.dart';
import 'package:multivendor_flutter_app/ui/admin/dashboard_page.dart';
import 'package:multivendor_flutter_app/ui/public/home_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/dashboard_page.dart';
import '../constants/app_enums.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings, Role userRole) {
    switch (settings.name) {
      /// USER ROUTES
      case RouteNames.home:
        if (userRole == Role.user) {
          return MaterialPageRoute(builder: (_) => const HomePage());
        }
        return _accessDeniedRoute();

      /// VENDOR ROUTES
      case RouteNames.vendorDashboard:
        if (userRole == Role.vendor) {
          return MaterialPageRoute(builder: (_) => const VendorDashboardPage());
        }
        return _accessDeniedRoute();

      /// ADMIN ROUTES
      case RouteNames.adminDashboard:
        if (userRole == Role.admin) {
          return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
        }
        return _accessDeniedRoute();

      default:
        return _unknownRoute();
    }
  }

  static Route<dynamic> _accessDeniedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text("Access Denied"))),
    );
  }

  static Route<dynamic> _unknownRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text("Page not found"))),
    );
  }
}
