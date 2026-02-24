// models/order_item.dart
class OrderItem {
  final int id;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String vendorName;
  final double subTotal;

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.vendorName,
    required this.subTotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'],
        productName: json['productName'],
        quantity: json['quantity'],
        unitPrice: (json['unitPrice'] as num).toDouble(),
        vendorName: json['vendorName'],
        subTotal: (json['subTotal'] as num).toDouble(),
      );
}

// models/order.dart
class Order {
  final int id;
  final String userName;
  final double totalPrice;
  final String orderStatus;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userName,
    required this.totalPrice,
    required this.orderStatus,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        userName: json['userName'],
        totalPrice: (json['totalPrice'] as num).toDouble(),
        orderStatus: json['orderStatus'],
        items: (json['items'] as List)
            .map((e) => OrderItem.fromJson(e))
            .toList(),
      );
}

// models/order_request.dart
class OrderItemRequest {
  final int productId;
  final int vendorId;
  final int quantity;
  final double unitPrice;

  OrderItemRequest({
    required this.productId,
    required this.vendorId,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "vendorId": vendorId,
        "quantity": quantity,
        "unitPrice": unitPrice,
      };
}

class OrderRequest {
  final String userName;
  final List<OrderItemRequest> items;

  OrderRequest({required this.userName, required this.items});

  Map<String, dynamic> toJson() => {
        "userName": userName,
        "items": items.map((e) => e.toJson()).toList(),
      };
}