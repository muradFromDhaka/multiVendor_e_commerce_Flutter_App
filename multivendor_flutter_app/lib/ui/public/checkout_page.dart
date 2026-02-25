import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/order.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/order_service.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/ui/user/orders_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<ProductResponse> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();

  bool _isSubmitting = false;

  double get totalPrice => widget.cartItems.fold(
        0,
        (sum, item) => sum + (item.price * item.cartQuantity),
      );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = await _authService.getCurrentUser();
      final userName = user?['userName'];

      if (userName == null || userName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      final items = widget.cartItems.map((item) {
        return OrderItemRequest(
          productId: item.id,
          vendorId: item.cartVendorId,
          quantity: item.cartQuantity,
        );
      }).toList();

      final request = OrderRequest(
        userName: userName,
        items: items,
      );

      await _orderService.createOrder(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully")),
      );

      // ✅ Prevent backstack সমস্যা
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrdersPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order failed: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _changeQty(ProductResponse item, int delta) {
    setState(() {
      final newQty = item.cartQuantity + delta;
      if (newQty > 0) {
        item.cartQuantity = newQty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        prefixIcon: Icon(Icons.home),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Cart Summary",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),

                    ...widget.cartItems.map(
                      (item) => Card(
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _changeQty(item, -1),
                              ),
                              Text("${item.cartQuantity}"),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _changeQty(item, 1),
                              ),
                              const SizedBox(width: 8),
                              Text("x \$${item.price.toStringAsFixed(2)}"),
                            ],
                          ),
                          trailing: Text(
                            "\$${(item.cartQuantity * item.price).toStringAsFixed(2)}",
                          ),
                        ),
                      ),
                    ),

                    const Divider(),

                    ListTile(
                      title: const Text(
                        "Total",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        "\$${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrder,
                  child: _isSubmitting
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : const Text("Place Order"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}