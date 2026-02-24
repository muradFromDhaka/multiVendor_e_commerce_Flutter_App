import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/cart.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/services/cart_service.dart';
import 'package:multivendor_flutter_app/ui/public/checkout_page.dart';
import 'package:multivendor_flutter_app/ui/user/user_home_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  final CartService _cartService = CartService();
  CartDto? cart;
  bool isLoading = true;
  bool isPlacingOrder = false;
  Set<String> loadingItems = {}; // Track loading state for individual items
  String? errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadCart();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _cartService.loadCart();
      if (!mounted) return;
      setState(() {
        cart = data;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cart = CartDto(items: [], totalAmount: 0);
        isLoading = false;
        errorMessage = "Failed to load cart. Please try again.";
      });
    }
  }

  Future<void> _increaseQty(ItemDto item) async {
    await _updateQuantity(item, item.quantity + 1);
  }

  Future<void> _decreaseQty(ItemDto item) async {
    if (item.quantity == 1) return;
    await _updateQuantity(item, item.quantity - 1);
  }

  Future<void> _updateQuantity(ItemDto item, int newQuantity) async {
    setState(() {
      loadingItems.add(item.itemId.toStringAsFixed(2));
    });

    try {
      final updated = await _cartService.updateCartItem(
        item.itemId,
        CartItemRequest(productId: item.productId, quantity: newQuantity),
      );

      if (!mounted) return;
      setState(() {
        cart = updated;
        loadingItems.remove(item.itemId);
      });

      // Show subtle feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Quantity updated to $newQuantity',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadingItems.remove(item.itemId);
      });
      _showErrorSnackBar('Failed to update quantity');
    }
  }

  Future<void> _removeItem(ItemDto item) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove "${item.productName}" from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (cart == null) return;

    final oldCart = cart!;
    final newItems = oldCart.items
        .where((i) => i.itemId != item.itemId)
        .toList();
    final newTotal = _cartService.calculateTotal(newItems);

    setState(() {
      cart = CartDto(items: newItems, totalAmount: newTotal);
    });

    try {
      final updated = await _cartService.removeCartItem(item.itemId);
      if (!mounted) return;
      if (updated != null) {
        setState(() => cart = updated);
        _showSuccessSnackBar('Item removed from cart');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => cart = oldCart);
      _showErrorSnackBar('Failed to remove item');
    }
  }

  Future<void> _clearCart() async {
    if (!mounted || cart?.items.isEmpty == true) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final oldCart = cart;
    setState(() {
      cart = CartDto(items: [], totalAmount: 0);
    });

    try {
      final updated = await _cartService.clearCart();
      if (!mounted) return;
      setState(() {
        updated.totalAmount = _cartService.calculateTotal(updated.items);
        cart = updated;
      });
      _showSuccessSnackBar('Cart cleared successfully');
    } catch (e) {
      if (!mounted) return;
      setState(() => cart = oldCart);
      _showErrorSnackBar('Failed to clear cart');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int get totalItems =>
      cart?.items.fold<int>(0, (sum, item) => sum + item.quantity) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          if (cart?.items.isNotEmpty == true)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearCart,
              tooltip: 'Clear cart',
            ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : errorMessage != null
          ? _buildErrorState()
          : (cart == null || cart!.items.isEmpty)
          ? _buildEmptyState()
          : _buildCartContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your cart...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCart,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added\nanything to your cart yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserHomePage()),
              ),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Continue Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCart,
              color: Theme.of(context).primaryColor,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cart!.items.length,
                itemBuilder: (context, index) {
                  final item = cart!.items[index];
                  final isLoading = loadingItems.contains(item.itemId);
                  return _buildCartItem(item, isLoading);
                },
              ),
            ),
          ),
          _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildCartItem(ItemDto item, bool isLoading) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade100,
                child: item.imageUrl != null
                    ? Image.network(
                        "${ApiConfig.imgBaseUrl}/${item.imageUrl!}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Product Details
            // Expanded(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         item.productName,
            //         style: const TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w600,
            //         ),
            //         maxLines: 2,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //       const SizedBox(height: 4),
            //       Text(
            //         '\$${item.price.toStringAsFixed(2)}',
            //         style: TextStyle(
            //           fontSize: 14,
            //           color: Colors.grey.shade700,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // ✅ Vendor Name
                  Text(
                    "${item.vendorName ?? 'Unknown Vendor'}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onPressed: isLoading ? null : () => _decreaseQty(item),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : Text(
                            item.quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onPressed: isLoading ? null : () => _increaseQty(item),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Delete Button
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade700,
                  size: 20,
                ),
                onPressed: isLoading ? null : () => _removeItem(item),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 16,
            color: onPressed == null ? Colors.grey.shade400 : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Items:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${cart?.totalAmount.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isPlacingOrder || cart?.items.isEmpty == true
                    ? null
                    : () {
                        // ✅ Vendor validation
                        for (var item in cart!.items) {
                          if ((item.vendorId ?? 0) <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Invalid vendor for product ${item.productName}",
                                ),
                                backgroundColor: Colors.red.shade600,
                              ),
                            );
                            return; // Stop navigation
                          }
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(
                              cartItems: cart!.items.map((item) {
                                return ProductResponse(
                                  id: item.productId,
                                  name: item.productName,
                                  price: item.price,
                                  sku: '',
                                  stockQuantity: 1,
                                  vendorId: item.vendorId ?? 0,
                                  vendorName: item.vendorName,
                                  cartQuantity: item.quantity,
                                  cartVendorId: item.vendorId ?? 0,
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isPlacingOrder
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Processing...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
