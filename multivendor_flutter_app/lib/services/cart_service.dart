import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multivendor_flutter_app/models/cart.dart';

class CartService {
  final String baseUrl = "http://your-api-url/cart";

  // Load Cart
  Future<CartDto> loadCart() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return CartDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load cart");
    }
  }

  // Add Item
  Future<CartDto> addItem(CartItemRequest request) async {
    final response = await http.post(
      Uri.parse("$baseUrl/add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return CartDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to add item");
    }
  }

  // Update Item
  Future<CartDto> updateCartItem(int cartItemId, CartItemRequest request) async {
    final response = await http.put(
      Uri.parse("$baseUrl/update/$cartItemId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return CartDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update item");
    }
  }

  // Remove Item
  Future<CartDto> removeCartItem(int cartItemId) async {
    final response = await http.delete(Uri.parse("$baseUrl/remove/$cartItemId"));

    if (response.statusCode == 200) {
      return CartDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to remove item");
    }
  }

  // Clear Cart
  Future<CartDto> clearCart() async {
    final response = await http.delete(Uri.parse("$baseUrl/clear"));

    if (response.statusCode == 200) {
      return CartDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to clear cart");
    }
  }
}