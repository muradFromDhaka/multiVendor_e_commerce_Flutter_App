import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/cart.dart';
import 'package:multivendor_flutter_app/services/cart_service.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  CartDto? cart;
  bool isLoading = true;
  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      final data = await _cartService.loadCart();
      setState(() {
        cart = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        cart = CartDto(items: [], totalAmount: 0);
        isLoading = false;
      });
    }
  }

  Future<void> increaseQty(ItemDto item) async {
    final updated = await _cartService.updateCartItem(
      item.itemId,
      CartItemRequest(productId: item.productId, quantity: item.quantity + 1),
    );
    setState(() => cart = updated);
  }

  Future<void> decreaseQty(ItemDto item) async {
    if (item.quantity == 1) return;
    final updated = await _cartService.updateCartItem(
      item.itemId,
      CartItemRequest(productId: item.productId, quantity: item.quantity - 1),
    );
    setState(() => cart = updated);
  }

  Future<void> removeItem(ItemDto item) async {
    final updated = await _cartService.removeCartItem(item.itemId);
    setState(() => cart = updated);
  }

  Future<void> clearCart() async {
    final updated = await _cartService.clearCart();
    setState(() => cart = updated);
  }

  int get totalItems => cart?.items.fold(0, (sum, i) => sum + i.quantity) ?? 0;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Shopping Cart")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (cart == null || cart!.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Shopping Cart")),
        body: Center(child: Text("Your cart is empty")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Shopping Cart")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart!.items.length,
              itemBuilder: (context, index) {
                final item = cart!.items[index];
                return ListTile(
                  leading: item.imageUrl != null
                      ? Image.network(item.imageUrl!)
                      : null,
                  title: Text(item.productName),
                  subtitle: Text("Price: \$${item.price}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => decreaseQty(item)),
                      Text(item.quantity.toString()),
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => increaseQty(item)),
                      IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => removeItem(item)),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Total Items: $totalItems"),
                SizedBox(height: 4),
                Text("Total Amount: \$${cart!.totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: clearCart,
                      // style: ElevatedButton.styleFrom(primary: Colors.red),
                      child: Text("Clear Cart"),
                    ),
                    ElevatedButton(
                      onPressed: isPlacingOrder ? null : () {},
                      // style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: Text(
                          isPlacingOrder ? "Placing Order..." : "Checkout"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}