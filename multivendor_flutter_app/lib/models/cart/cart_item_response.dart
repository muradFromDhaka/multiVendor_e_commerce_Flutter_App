// lib/models/cart/cart_item_response.dart
class CartItemResponse {
  final int itemId;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;
  final String? imageUrl;

  CartItemResponse({
    required this.itemId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
    this.imageUrl,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      itemId: json['itemId'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}