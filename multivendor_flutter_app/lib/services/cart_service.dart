// lib/services/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multivendor_flutter_app/models/cart/cart_dto.dart';
import 'package:multivendor_flutter_app/models/cart/cart_item_request.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/ui/user/user_cart/logger.dart';

class CartService {
  final AuthService _authService = AuthService();
  
  Uri _url(String path) => Uri.parse("${ApiConfig.baseUrl}$path");

  Future<Map<String, String>> _getHeaders() async {
    return await _authService.headers(auth: true);
  }

  // Get Cart
  Future<CartDto> getCart() async {
    try {
      Logger.info('Fetching cart...');
      
      final response = await http.get(
        _url("/api/cart"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      Logger.info('Get cart response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CartDto.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Please login to view cart');
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error fetching cart: $e');
      rethrow;
    }
  }

  // Add Item to Cart
  Future<CartDto> addToCart(CartItemRequest request) async {
    try {
      Logger.info('Adding item to cart. Product ID: ${request.productId}, Quantity: ${request.quantity}');
      
      final response = await http.post(
        _url("/api/cart/add"),
        headers: {
          ...await _getHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      Logger.info('Add to cart response status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CartDto.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Please login to add items to cart');
      } else {
        throw Exception('Failed to add item to cart: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error adding to cart: $e');
      rethrow;
    }
  }

  // Update Cart Item
  Future<CartDto> updateCartItem(int cartItemId, CartItemRequest request) async {
    try {
      Logger.info('Updating cart item. Item ID: $cartItemId, Quantity: ${request.quantity}');
      
      final response = await http.put(
        _url("/api/cart/update/$cartItemId"),
        headers: {
          ...await _getHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      Logger.info('Update cart item response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CartDto.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Please login to update cart');
      } else {
        throw Exception('Failed to update cart item: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error updating cart item: $e');
      rethrow;
    }
  }

  // Remove Cart Item
  Future<void> removeCartItem(int cartItemId) async {
    try {
      Logger.info('Removing cart item. Item ID: $cartItemId');
      
      final response = await http.delete(
        _url("/api/cart/remove/$cartItemId"),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      Logger.info('Remove cart item response status: ${response.statusCode}');
      
      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Please login to remove items from cart');
      } else {
        throw Exception('Failed to remove cart item: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error removing cart item: $e');
      rethrow;
    }
  }

  // Clear entire cart (optional - backend may not have this endpoint)
  Future<void> clearCart() async {
    try {
      final cart = await getCart();
      for (var item in cart.items) {
        await removeCartItem(item.itemId);
      }
      Logger.info('Cart cleared successfully');
    } catch (e) {
      Logger.error('Error clearing cart: $e');
      rethrow;
    }
  }
}