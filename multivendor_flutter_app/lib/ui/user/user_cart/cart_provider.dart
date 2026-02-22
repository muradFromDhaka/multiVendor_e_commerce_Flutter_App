// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/cart/cart_dto.dart';
import 'package:multivendor_flutter_app/models/cart/cart_item_request.dart';
import 'package:multivendor_flutter_app/models/cart/cart_item_response.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/cart_service.dart';
import 'package:multivendor_flutter_app/ui/user/user_cart/logger.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  CartDto? _cart;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  CartDto? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  int get itemCount => _cart?.items.length ?? 0;
  double get totalAmount => _cart?.totalAmount ?? 0.0;

  List<CartItemResponse> get items => _cart?.items ?? [];

  // Set authentication state
  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    if (!value) {
      _cart = null; // Clear cart when user logs out
    }
    notifyListeners();
  }

  // Load Cart
  Future<bool> loadCart() async {
    if (!_isAuthenticated) {
      _errorMessage = 'Please login to view cart';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      _cart = await _cartService.getCart();
      Logger.info('Cart loaded successfully. Items: ${_cart?.items.length}');
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      Logger.error('Failed to load cart: $e');
      return false;
    }
  }

  // Add to Cart
  Future<bool> addToCart(ProductResponse product, {int quantity = 1}) async {
    if (!_isAuthenticated) {
      _errorMessage = 'Please login to add items to cart';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final request = CartItemRequest(
        productId: product.id,
        quantity: quantity,
      );

      _cart = await _cartService.addToCart(request);
      Logger.info('Item added to cart: ${product.name}');
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      Logger.error('Failed to add to cart: $e');
      return false;
    }
  }

  // Update Cart Item
  Future<bool> updateCartItem(int cartItemId, int quantity) async {
    if (!_isAuthenticated) return false;

    _setLoading(true);
    _clearError();

    try {
      // Find the product ID from existing cart item
      final existingItem = _cart?.items.firstWhere(
        (item) => item.itemId == cartItemId,
      );

      if (existingItem == null) {
        throw Exception('Cart item not found');
      }

      final request = CartItemRequest(
        productId: existingItem.productId,
        quantity: quantity,
      );

      _cart = await _cartService.updateCartItem(cartItemId, request);
      Logger.info(
        'Cart item updated. Item ID: $cartItemId, Quantity: $quantity',
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      Logger.error('Failed to update cart item: $e');
      return false;
    }
  }

  // Remove Cart Item
  Future<bool> removeCartItem(int cartItemId) async {
    if (!_isAuthenticated) return false;

    _setLoading(true);
    _clearError();

    try {
      await _cartService.removeCartItem(cartItemId);

      // API কল成功后, আবার cart reload করুন
      _cart = await _cartService.getCart(); // ✅ fresh data

      Logger.info('Cart item removed. Item ID: $cartItemId');
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      Logger.error('Failed to remove cart item: $e');
      return false;
    }
  }

  // Clear Cart
  Future<bool> clearCart() async {
    if (!_isAuthenticated) return false;

    _setLoading(true);
    _clearError();

    try {
      await _cartService.clearCart();
      _cart = null;
      Logger.info('Cart cleared');
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      Logger.error('Failed to clear cart: $e');
      return false;
    }
  }

  // Helper Methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Refresh Cart
  Future<void> refreshCart() async {
    await loadCart();
  }
}
