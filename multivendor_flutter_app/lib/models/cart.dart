class CartDto {
  final int? cartId;
  final List<ItemDto> items;
  double totalAmount;

  CartDto({this.cartId, required this.items, required this.totalAmount});

  factory CartDto.fromJson(Map<String, dynamic> json) {
    return CartDto(
      cartId: json['cartId'],
      items: (json['items'] as List)
          .map((e) => ItemDto.fromJson(e))
          .toList(),
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

  // ✅ Add vendor info
  final int? vendorId;
  final String? vendorName;

  ItemDto({
    required this.itemId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
    this.imageUrl,
    this.vendorId,      // ✅ constructor add
    this.vendorName,    // ✅ constructor add
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
      vendorId: json['vendorId'],        // ✅ map from JSON
      vendorName: json['vendorName'],    // ✅ map from JSON
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