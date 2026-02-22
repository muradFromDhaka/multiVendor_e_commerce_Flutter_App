// lib/ui/public/cart/cart_page.dart
import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/cart/cart_item_response.dart';
import 'package:multivendor_flutter_app/ui/user/user_cart/cart_item.dart';
import 'package:multivendor_flutter_app/ui/user/user_cart/cart_provider.dart';
import 'package:multivendor_flutter_app/ui/user/user_cart/price_formatter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.isAuthenticated) {
      await cartProvider.loadCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.isAuthenticated && cartProvider.itemCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  onPressed: () => _showClearCartDialog(context, cartProvider),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (!cartProvider.isAuthenticated) {
            return _buildLoginPrompt();
          }

          if (cartProvider.isLoading) {
            return _buildLoadingShimmer();
          }

          if (cartProvider.errorMessage != null) {
            return _buildErrorView(cartProvider.errorMessage!);
          }

          if (cartProvider.itemCount == 0) {
            return _buildEmptyCart();
          }

          return _buildCartContent(cartProvider);
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (!cartProvider.isAuthenticated || cartProvider.itemCount == 0) {
            return const SizedBox.shrink();
          }
          return _buildCheckoutBar(cartProvider);
        },
      ),
    );
  }

  Widget _buildCartContent(CartProvider cartProvider) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: cartProvider.refreshCart,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartProvider.itemCount,
              itemBuilder: (context, index) {
                final item = cartProvider.items[index];
                return CartItemWidget(
                  item: item,
                  onQuantityChanged: (newQuantity) async {
                    if (newQuantity > 0) {
                      await cartProvider.updateCartItem(item.itemId, newQuantity);
                    } else {
                      _showRemoveDialog(context, cartProvider, item);
                    }
                  },
                  onRemove: () {
                    _showRemoveDialog(context, cartProvider, item);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    PriceFormatter.format(cartProvider.totalAmount),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to checkout
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Proceeding to checkout...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your cart is waiting',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please login to view and manage your cart items',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to login page
              },
              icon: const Icon(Icons.login),
              label: const Text('Login'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added anything to your cart yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Continue Shopping'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load cart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCart,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRemoveDialog(
    BuildContext context,
    CartProvider cartProvider,
    CartItemResponse item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Are you sure you want to remove "${item.productName}" from your cart?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cartProvider.removeCartItem(item.itemId);
    }
  }

  Future<void> _showClearCartDialog(BuildContext context, CartProvider cartProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cartProvider.clearCart();
    }
  }
}