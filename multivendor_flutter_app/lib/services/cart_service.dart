
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multivendor_flutter_app/core/network/api_exceptions.dart';
import 'package:multivendor_flutter_app/models/cart.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';

class CartService {
  final AuthService _authService = AuthService();
  CartDto? currentCart;

  // Load Cart
  Future<CartDto> loadCart() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/cart"),
        headers: await _authService.headers(auth: true),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentCart = CartDto.fromJson(jsonDecode(response.body));
        return currentCart!;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw Exception("Failed to load cart");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add Item
  Future<CartDto> addItem(CartItemRequest request) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/cart/add"),
        headers: await _authService.headers(auth: true),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentCart = CartDto.fromJson(jsonDecode(response.body));
        return currentCart!;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw Exception("Failed to add item");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update Item
  Future<CartDto> updateCartItem(
    int cartItemId,
    CartItemRequest request,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/cart/update/$cartItemId"),
        headers: await _authService.headers(auth: true),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentCart = CartDto.fromJson(jsonDecode(response.body));
        return currentCart!;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw Exception("Failed to update item");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Remove Item
  // Future<CartDto?> removeCartItem(int cartItemId) async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse("${ApiConfig.baseUrl}/cart/remove/$cartItemId"),
  //       headers: await _authService.headers(auth: true),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       currentCart = CartDto.fromJson(jsonDecode(response.body));
  //     } else if (response.statusCode == 204) {
  //       // No content → remove item locally
  //       if (currentCart != null) {
  //         currentCart!.items.removeWhere((i) => i.itemId == cartItemId);
  //       }
  //     } else if (response.statusCode == 401) {
  //       throw UnauthorizedException();
  //     } else {
  //       throw Exception("Failed to remove item");
  //     }

  //     return currentCart;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // // Clear Cart
  // Future<CartDto> clearCart() async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse("${ApiConfig.baseUrl}/cart/clear"),
  //       headers: await _authService.headers(auth: true),
  //     );

  //     if (response.statusCode == 200 ||
  //         response.statusCode == 201 ||
  //         response.statusCode == 204) {
  //       currentCart = CartDto(items: [], totalAmount: 0);
  //     } else if (response.statusCode == 401) {
  //       throw UnauthorizedException();
  //     } else {
  //       throw Exception("Failed to clear cart");
  //     }

  //     return currentCart!;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  double calculateTotal(List<ItemDto> items) {
    return items.fold<double>(0, (sum, i) => sum + i.price * i.quantity);
  }

  Future<CartDto?> removeCartItem(int cartItemId) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/cart/remove/$cartItemId"),
        headers: await _authService.headers(auth: true),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentCart = CartDto.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 204) {
        if (currentCart != null) {
          currentCart!.items.removeWhere((i) => i.itemId == cartItemId);
          currentCart!.totalAmount = calculateTotal(currentCart!.items);
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw Exception("Failed to remove item");
      }

      return currentCart;
    } catch (e) {
      rethrow;
    }
  }

  Future<CartDto> clearCart() async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/cart/clear"),
        headers: await _authService.headers(auth: true),
      );

      debugPrint("clearCart Status: ${response.statusCode}");
      debugPrint("clearCart Body: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        currentCart = CartDto(items: [], totalAmount: 0);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw Exception("Failed to clear cart");
      }

      return currentCart!;
    } catch (e) {
      rethrow;
    }
  }
}
