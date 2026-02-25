// // import 'package:flutter/material.dart';

// // class VendorPayoutPage extends StatelessWidget {
// //   const VendorPayoutPage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(body: Center(child: Text("Payout page.......")));
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:multivendor_flutter_app/services/order_service.dart';
// import 'package:intl/intl.dart';

// class VendorPayoutPage extends StatefulWidget {
//   const VendorPayoutPage({super.key});

//   @override
//   State<VendorPayoutPage> createState() => _VendorPayoutPageState();
// }

// class _VendorPayoutPageState extends State<VendorPayoutPage> {
//   final OrderService _orderService = OrderService();
//   final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

//   double _availableBalance = 0.0;
//   bool _isLoading = true;

//   final TextEditingController _amountController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _fetchBalance();
//   }

//   Future<void> _fetchBalance() async {
//     setState(() => _isLoading = true);
//     try {
//       final orders = await _orderService.getVendorOrders();
//       double total = 0.0;
//       for (var order in orders) {
//         for (var item in order.items) {
//           total += item.unitPrice * item.quantity;
//         }
//       }
//       setState(() => _availableBalance = total);
//     } catch (e) {
//       print("Error fetching balance: $e");
//       setState(() => _availableBalance = 0.0);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _submitWithdrawal() {
//     if (!_formKey.currentState!.validate()) return;

//     final amount = double.parse(_amountController.text);
//     // Call your API to withdraw amount
//     // Example: _orderService.withdraw(amount);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Withdrawal of ${_currencyFormat.format(amount)} submitted!',
//         ),
//         backgroundColor: Colors.green,
//       ),
//     );
//     _amountController.clear();
//     _fetchBalance(); // refresh balance
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Withdraw Funds"),
//         backgroundColor: Colors.green,
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Available Balance",
//                           style: TextStyle(color: Colors.white70, fontSize: 14),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _currencyFormat.format(_availableBalance),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 36,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Form(
//                     key: _formKey,
//                     child: TextFormField(
//                       controller: _amountController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: "Enter amount to withdraw",
//                         prefixText: '\$ ',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty)
//                           return "Please enter amount";
//                         final amount = double.tryParse(value);
//                         if (amount == null) return "Enter a valid number";
//                         if (amount <= 0) return "Amount must be greater than 0";
//                         if (amount > _availableBalance)
//                           return "Insufficient balance";
//                         return null;
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _submitWithdrawal,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text(
//                         "Withdraw",
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/order_service.dart';
import 'package:intl/intl.dart';

class VendorPayoutPage extends StatefulWidget {
  const VendorPayoutPage({super.key});

  @override
  State<VendorPayoutPage> createState() => _VendorPayoutPageState();
}

class _VendorPayoutPageState extends State<VendorPayoutPage> {
  final OrderService _orderService = OrderService();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  double _availableBalance = 0.0;
  bool _isLoading = true;

  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _withdrawalHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _fetchWithdrawalHistory();
  }

  Future<void> _fetchBalance() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.getVendorOrders();
      double total = 0.0;
      for (var order in orders) {
        for (var item in order.items) {
          total += item.unitPrice * item.quantity;
        }
      }
      setState(() => _availableBalance = total);
    } catch (e) {
      print("Error fetching balance: $e");
      setState(() => _availableBalance = 0.0);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Mock API call for withdrawal history
  Future<void> _fetchWithdrawalHistory() async {
    // Replace with actual API call
    _withdrawalHistory = [
      {"amount": 50.0, "date": DateTime.now().subtract(const Duration(days: 1)), "status": "Completed"},
      {"amount": 30.0, "date": DateTime.now().subtract(const Duration(days: 3)), "status": "Completed"},
    ];
    setState(() {});
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    // 1️⃣ Call API to withdraw amount
    try {
      setState(() => _isLoading = true);
      // await _orderService.withdraw(amount); // uncomment and implement in service

      // 2️⃣ Update local withdrawal history (remove this if API returns actual data)
      _withdrawalHistory.insert(0, {
        "amount": amount,
        "date": DateTime.now(),
        "status": "Pending",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Withdrawal of ${_currencyFormat.format(amount)} submitted!'),
          backgroundColor: Colors.green,
        ),
      );

      _amountController.clear();
      await _fetchBalance(); // refresh available balance
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting withdrawal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Payout"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchBalance();
                await _fetchWithdrawalHistory();
              },
              color: Colors.green,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Available balance
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Available Balance",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currencyFormat.format(_availableBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Withdraw form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Enter amount to withdraw",
                              prefixText: '\$ ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return "Please enter amount";
                              final amount = double.tryParse(value);
                              if (amount == null) return "Enter a valid number";
                              if (amount <= 0) return "Amount must be greater than 0";
                              if (amount > _availableBalance)
                                return "Insufficient balance";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitWithdrawal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Withdraw",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Withdrawal history
                    const Text(
                      "Withdrawal History",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_withdrawalHistory.isEmpty)
                      const Text("No withdrawals yet")
                    else
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _withdrawalHistory.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final withdrawal = _withdrawalHistory[index];
                          final date = withdrawal['date'] as DateTime;
                          final amount = withdrawal['amount'] as double;
                          final status = withdrawal['status'] as String;
                          return ListTile(
                            leading: Icon(
                              status == "Completed" ? Icons.check_circle : Icons.pending,
                              color: status == "Completed" ? Colors.green : Colors.orange,
                            ),
                            title: Text(_currencyFormat.format(amount)),
                            subtitle: Text(DateFormat('MMM d, yyyy – hh:mm a').format(date)),
                            trailing: Text(status),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}