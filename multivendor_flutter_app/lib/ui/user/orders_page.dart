
import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/order.dart';
import 'package:multivendor_flutter_app/services/order_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderService _orderService = OrderService();

  bool isLoading = true;
  List<OrderResponse> orders = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await _orderService.getMyOrders();

      if (!mounted) return;

      setState(() {
        orders = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text("Error: $error"));
    }

    if (orders.isEmpty) {
      return const Center(child: Text("No orders yet"));
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            child: ExpansionTile(
              title: Text("Order #${order.id}"),
              subtitle: Text("Status: ${order.orderStatus}"),
              trailing: Text("৳ ${order.totalPrice.toStringAsFixed(2)}"),
              children: order.items.map((item) {
                return ListTile(
                  title: Text(item.productName),
                  subtitle: Text("Qty: ${item.quantity} × ৳${item.unitPrice}"),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}



