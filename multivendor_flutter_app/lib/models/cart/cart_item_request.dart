// lib/models/cart/cart_item_request.dart
class CartItemRequest {
  final int productId;
  final int quantity;

  CartItemRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}