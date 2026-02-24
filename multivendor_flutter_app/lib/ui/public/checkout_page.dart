// ui/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/order.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/order_service.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';

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

  // Total price using cartQuantity
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
      final userName = await _authService.getCurrentUser().then(
        (user) => user?['userName'] ?? '',
      );

      if (userName.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in!")));
        return;
      }

      final items = widget.cartItems.map((item) {
        return OrderItemRequest(
          productId: item.id,
          vendorId: item.cartVendorId, // frontend vendorId
          quantity: item.cartQuantity, // frontend quantity
          unitPrice: item.price,
        );
      }).toList();

      final orderRequest = OrderRequest(userName: userName, items: items);

      await _orderService.createOrder(orderRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );

      Navigator.pop(context, true); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 10),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 10),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        prefixIcon: Icon(Icons.home),
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    const Text("Cart Summary", style: TextStyle(fontSize: 16)),
                    const Divider(),

                    // Cart Items
                    ...widget.cartItems.map(
                      (item) => ListTile(
                        title: Text(item.name),
                        subtitle: Row(
                          children: [
                            // Decrease quantity
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (item.cartQuantity > 1) {
                                  setState(() => item.cartQuantity--);
                                }
                              },
                            ),
                            Text("${item.cartQuantity}"),
                            // Increase quantity
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() => item.cartQuantity++);
                              },
                            ),
                            const SizedBox(width: 10),
                            Text("x \$${item.price.toStringAsFixed(2)}"),
                          ],
                        ),
                        trailing: Text(
                          "\$${(item.cartQuantity * item.price).toStringAsFixed(2)}",
                        ),
                      ),
                    ),
                    const Divider(),

                    // Total
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

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Place Order",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
