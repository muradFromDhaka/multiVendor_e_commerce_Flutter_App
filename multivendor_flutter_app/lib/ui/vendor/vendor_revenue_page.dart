import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/order_service.dart';

class VendorRevenuePage extends StatefulWidget {
  const VendorRevenuePage({super.key});

  @override
  State<VendorRevenuePage> createState() => _VendorRevenuePageState();
}

class _VendorRevenuePageState extends State<VendorRevenuePage> {
  final OrderService _service = OrderService();
  late Future<double> _future;

  @override
  void initState() {
    super.initState();
    _loadRevenue();
  }

  void _loadRevenue() {
    _future = _service.getVendorRevenue();
  }

  Future<void> _refresh() async {
    setState(() => _loadRevenue());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Revenue :-"),
        // centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<double>(
          future: _future,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingView();
            }

            if (snapshot.hasError) {
              return _ErrorView(
                error: snapshot.error.toString(),
                onRetry: () => setState(() => _loadRevenue()),
              );
            }

            final revenue = snapshot.data ?? 0;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _RevenueCard(revenue: revenue),

                const SizedBox(height: 20),

                if (revenue == 0)
                  const _EmptyRevenueView()
                else
                  const _RevenueHint(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final double revenue;

  const _RevenueCard({required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.monetization_on, size: 48, color: Colors.white),
          const SizedBox(height: 10),
          const Text(
            "Total Revenue",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            "\$${revenue.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}

class _EmptyRevenueView extends StatelessWidget {
  const _EmptyRevenueView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 40),
        Icon(Icons.trending_down, size: 48, color: Colors.grey),
        SizedBox(height: 10),
        Text(
          "No revenue yet",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}

class _RevenueHint extends StatelessWidget {
  const _RevenueHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.trending_up, color: Colors.green),
        SizedBox(height: 6),
        Text(
          "Great! Your store is generating revenue.",
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
