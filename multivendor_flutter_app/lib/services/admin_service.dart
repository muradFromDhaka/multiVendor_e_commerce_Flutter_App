import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';

class AdminService {
  final AuthService _authService = AuthService();

  /// ✅ GET ALL ROLES
  Future<List<dynamic>> getAllRoles() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/admin/roles"),
      headers: await _authService.headers(auth: true),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load roles (${res.statusCode})");
  }

  /// ✅ CREATE ROLE
  Future<bool> createRole({
    required String roleName,
    required String roleDescription,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/admin/roles"),
      headers: await _authService.headers(auth: true),
      body: jsonEncode({
        "roleName": roleName,
        "roleDescription": roleDescription,
      }),
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }

  /// ✅ UPDATE USER ROLES
  Future<bool> updateUserRoles({
    required String username,
    required List<String> roles,
  }) async {
    final res = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/admin/users/$username/roles"),
      headers: await _authService.headers(auth: true),
      body: jsonEncode({
        "roles": roles,
      }),
    );

    return res.statusCode == 200;
  }

  /// ✅ GET USERS BY ROLE
  Future<List<dynamic>> getUsersByRole(String roleName) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/admin/roles/$roleName/users"),
      headers: await _authService.headers(auth: true),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load users (${res.statusCode})");
  }

  /// ✅ SYSTEM STATISTICS (SUPER ADMIN ONLY)
  Future<Map<String, dynamic>> getStatistics() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/admin/statistics"),
      headers: await _authService.headers(auth: true),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    if (res.statusCode == 403) {
      throw Exception("Access Denied (SUPER_ADMIN only)");
    }

    throw Exception("Failed to load statistics (${res.statusCode})");
  }
}