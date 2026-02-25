// import 'package:flutter/material.dart';
// import 'package:multivendor_flutter_app/services/order_service.dart';
// import 'package:multivendor_flutter_app/ui/vendor/vendor_orders_page.dart';
// import 'package:intl/intl.dart';

// class VendorEarningsPage extends StatefulWidget {
//   const VendorEarningsPage({super.key});

//   @override
//   State<VendorEarningsPage> createState() => _VendorEarningsPageState();
// }

// class _VendorEarningsPageState extends State<VendorEarningsPage> {
//   final OrderService _orderService = OrderService();
//   late Future<Map<String, dynamic>> _futureEarningsData;

//   final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

//   @override
//   void initState() {
//     super.initState();
//     _futureEarningsData = _fetchEarningsData();
//   }

//   // ---------------- Fetch orders and calculate earnings ----------------
//   Future<Map<String, dynamic>> _fetchEarningsData() async {
//     try {
//       final orders = await _orderService.getVendorOrders();

//       double totalEarnings = 0.0;
//       int totalOrders = orders.length;
//       int totalItems = 0;
//       double averageOrderValue = 0.0;

//       for (var order in orders) {
//         for (var item in order.items) {
//           totalEarnings += item.unitPrice * item.quantity;
//           totalItems += item.quantity;
//         }
//       }

//       if (totalOrders > 0) {
//         averageOrderValue = totalEarnings / totalOrders;
//       }

//       return {
//         'totalEarnings': totalEarnings,
//         'totalOrders': totalOrders,
//         'totalItems': totalItems,
//         'averageOrderValue': averageOrderValue,
//       };
//     } catch (e) {
//       print("Error fetching earnings: $e");
//       return {
//         'totalEarnings': 0.0,
//         'totalOrders': 0,
//         'totalItems': 0,
//         'averageOrderValue': 0.0,
//       };
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text("Vendor Earnings"),
//         backgroundColor: Colors.green,
//         centerTitle: true,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _futureEarningsData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }

//           final data = snapshot.data!;
//           final totalEarnings = data['totalEarnings'] as double;
//           final totalOrders = data['totalOrders'] as int;
//           final totalItems = data['totalItems'] as int;
//           final averageOrderValue = data['averageOrderValue'] as double;

//           return RefreshIndicator(
//             onRefresh: () async {
//               setState(() {
//                 _futureEarningsData = _fetchEarningsData();
//               });
//             },
//             color: Colors.green,
//             child: SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Total Earnings Card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Total Earnings",
//                           style: TextStyle(color: Colors.white70),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _currencyFormat.format(totalEarnings),
//                           style: const TextStyle(
//                             fontSize: 40,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Average per order: ${_currencyFormat.format(averageOrderValue)}",
//                           style: const TextStyle(color: Colors.white70),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Stats Cards
//                   Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           child: _buildStatCard(
//                             icon: Icons.shopping_bag_outlined,
//                             label: "Total Orders",
//                             value: totalOrders.toString(),
//                             color: Colors.blue,
//                           ),
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => VendorOrdersPage(),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: _buildStatCard(
//                           icon: Icons.inventory_2_outlined,
//                           label: "Items Sold",
//                           value: totalItems.toString(),
//                           color: Colors.purple,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 4),
//           Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/order_service.dart';
import 'package:multivendor_flutter_app/ui/vendor/payouts_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/vendor_orders_page.dart';
import 'package:intl/intl.dart';

class VendorEarningsPage extends StatefulWidget {
  const VendorEarningsPage({super.key});

  @override
  State<VendorEarningsPage> createState() => _VendorEarningsPageState();
}

class _VendorEarningsPageState extends State<VendorEarningsPage> {
  final OrderService _orderService = OrderService();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  late Future<Map<String, dynamic>> _futureEarningsData;

  @override
  void initState() {
    super.initState();
    _futureEarningsData = _fetchEarningsData();
  }

  // Fetch backend orders and calculate earnings dynamically
  Future<Map<String, dynamic>> _fetchEarningsData() async {
    try {
      final orders = await _orderService.getVendorOrders();

      double totalEarnings = 0.0;
      int totalOrders = orders.length;
      int totalItems = 0;

      for (var order in orders) {
        for (var item in order.items) {
          totalEarnings += item.unitPrice * item.quantity;
          totalItems += item.quantity;
        }
      }

      double averageOrderValue = totalOrders > 0
          ? totalEarnings / totalOrders
          : 0.0;

      return {
        'totalEarnings': totalEarnings,
        'totalOrders': totalOrders,
        'totalItems': totalItems,
        'averageOrderValue': averageOrderValue,
      };
    } catch (e) {
      print("Error fetching earnings: $e");
      return {
        'totalEarnings': 0.0,
        'totalOrders': 0,
        'totalItems': 0,
        'averageOrderValue': 0.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Vendor Earnings"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureEarningsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          final totalEarnings = data['totalEarnings'] as double;
          final totalOrders = data['totalOrders'] as int;
          final totalItems = data['totalItems'] as int;
          final averageOrderValue = data['averageOrderValue'] as double;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureEarningsData = _fetchEarningsData();
              });
            },
            color: Colors.green,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Total Earnings Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Earnings",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currencyFormat.format(totalEarnings),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Average per order: ${_currencyFormat.format(averageOrderValue)}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: _buildStatCard(
                            icon: Icons.shopping_bag_outlined,
                            label: "Total Orders",
                            value: totalOrders.toString(),
                            color: Colors.blue,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VendorOrdersPage(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.inventory_2_outlined,
                          label: "Items Sold",
                          value: totalItems.toString(),
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Withdraw Button (goes to Payout page)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: totalEarnings > 0
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VendorPayoutPage(),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Withdraw Funds",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
