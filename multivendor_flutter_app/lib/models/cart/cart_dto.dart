// lib/models/cart/cart_dto.dart
import 'cart_item_response.dart';

class CartDto {
  final int cartId;
  final List<CartItemResponse> items;
  double totalAmount;

  CartDto({
    required this.cartId,
    required this.items,
    required this.totalAmount,
  });

  factory CartDto.fromJson(Map<String, dynamic> json) {
    return CartDto(
      cartId: json['cartId'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((item) => CartItemResponse.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}
