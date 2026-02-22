class CartDto {
  final int? cartId;
  final List<ItemDto> items;
  double totalAmount;

  CartDto({this.cartId, required this.items, required this.totalAmount});

  factory CartDto.fromJson(Map<String, dynamic> json) {
    return CartDto(
      cartId: json['cartId'],
      items: (json['items'] as List).map((e) => ItemDto.fromJson(e)).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }
}

class ItemDto {
  final int itemId;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;
  final String? imageUrl;

  ItemDto({
    required this.itemId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
    this.imageUrl,
  });

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      itemId: json['itemId'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}

class CartItemRequest {
  final int productId;
  final int quantity;

  CartItemRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {"productId": productId, "quantity": quantity};
  }
}
