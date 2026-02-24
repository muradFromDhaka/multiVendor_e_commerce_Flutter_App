// services/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multivendor_flutter_app/models/order.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'auth_service.dart';

class OrderService {
  final AuthService _authService = AuthService();

  Future<Order> createOrder(OrderRequest request) async {
    final token = await _authService.getToken();
    print(
      "Creating order with token:---------------------------- $token and request: ${request.toJson()}",
    );
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/orders"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode == 200) {
      return Order.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Order creation failed: ${res.body}");
    }
  }

  Future<List<Order>> getMyOrders() async {
    final token = await _authService.getToken();
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/orders/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch orders: ${res.body}");
    }
  }
}
