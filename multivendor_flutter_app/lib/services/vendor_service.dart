import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart'; 

class VendorService {
  final _authService = AuthService();

  /* ================= CREATE VENDOR ================= */
  Future<Map<String, dynamic>> createVendor(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/vendors"),
      headers: await _authService.headers(),
      body: jsonEncode(body),
    );

    _checkError(res);

    return jsonDecode(res.body);
  }

  /* ================= GET ALL VENDORS (ADMIN) ================= */

  Future<List<dynamic>> getAllVendors() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/vendors'), headers: await _authService.headers());

    _checkError(res);

    return jsonDecode(res.body);
  }

  /* ================= GET VENDOR BY ID ================= */

  Future<Map<String, dynamic>> getVendorById(int id) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/vendors/$id"),
      headers: await _authService.headers(),
    );

    _checkError(res);

    return jsonDecode(res.body);
  }

  /* ================= UPDATE VENDOR ================= */

  Future<Map<String, dynamic>> updateVendor(
    int id,
    Map<String, dynamic> body,
  ) async {
    final res = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/vendors/$id"),
      headers: await _authService.headers(),
      body: jsonEncode(body),
    );

    _checkError(res);

    return jsonDecode(res.body);
  }

  /* ================= DELETE VENDOR ================= */

  Future<void> deleteVendor(int id) async {
    final res = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/vendors/$id"),
      headers: await _authService.headers(),
    );

    _checkError(res);
  }

  /* ================= GET MY VENDOR ================= */

  Future<Map<String, dynamic>> getMyVendor() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/vendors/me"),
      headers: await _authService.headers(),
    );

    _checkError(res);

    return jsonDecode(res.body);
  }

  /* ================= GET MY ORDER ITEMS ================= */

  Future<List<dynamic>> getMyOrderItems() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/vendors/me/order-items"),
      headers: await _authService.headers(),
    );

    _checkError(res);

    return jsonDecode(res.body);
  }

  /* ================= GET MY ORDERS ================= */

  Future<List<dynamic>> getMyOrders() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/vendors/me/orders"),
      headers: await _authService.headers(),
    );

    _checkError(res);

    return jsonDecode(res.body);
  }

  /* ================= ERROR HANDLER ================= */

  void _checkError(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;

    try {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? "Server Error");
    } catch (_) {
      throw Exception("HTTP ${res.statusCode}");
    }
  }
}
