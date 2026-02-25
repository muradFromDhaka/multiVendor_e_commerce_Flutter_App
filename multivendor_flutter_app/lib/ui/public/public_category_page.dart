// import 'package:flutter/material.dart';
// import 'package:multivendor_flutter_app/models/cart.dart';
// import 'package:multivendor_flutter_app/models/product/product_response.dart';
// import 'package:multivendor_flutter_app/services/ProductService.dart';
// import 'package:multivendor_flutter_app/services/api_config.dart';
// import 'package:multivendor_flutter_app/services/auth_service.dart';
// import 'package:multivendor_flutter_app/services/cart_service.dart';
// import 'package:multivendor_flutter_app/ui/public/cart_page.dart';

// class CategoryProductsPage extends StatefulWidget {
//   final int categoryId;
//   final String categoryName;

//   const CategoryProductsPage({
//     super.key,
//     required this.categoryId,
//     required this.categoryName,
//   });

//   @override
//   State<CategoryProductsPage> createState() => _CategoryProductsPageState();
// }

// class _CategoryProductsPageState extends State<CategoryProductsPage> {
//   final ProductService _productService = ProductService();
//   final CartService _cartService = CartService();
//   final AuthService _authService = AuthService();

//   bool _isLoading = true;
//   List<ProductResponse> _products = [];
//   String? _errorMessage;
//   int _cartCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//     _loadCartCount();
//   }

//   Future<void> _fetchProducts() async {
//     try {
//       final user = await _authService.getCurrentUser();
//       if (user == null) {
//         setState(() {
//           _errorMessage = 'Please login first';
//           _isLoading = false;
//         });
//         return;
//       }

//       final products = await _productService.getProductsByCategory(
//         widget.categoryId,
//       );
//       setState(() {
//         _products = products;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load products: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadCartCount() async {
//     final cart = await _cartService.loadCart();
//     setState(() {
//       _cartCount = cart.items.fold<int>(0, (sum, item) => sum + item.quantity);
//     });
//   }

//   Future<void> _addToCart(ProductResponse product) async {
//     try {
//       // Convert ProductResponse to CartItemRequest
//       final request = CartItemRequest(
//         productId: product.id,
//         quantity: 1,
//         // vendorId: product.vendorId ?? 0,
//       );

//       // Call the actual method in CartService
//       await _cartService.addItem(request);

//       // Reload cart count
//       await _loadCartCount();

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('${product.name} added to cart')));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add ${product.name}: $e')),
//       );
//     }
//   }

//   void _buyNow(ProductResponse product) {
//     _addToCart(product).then((_) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const CartPage()),
//       );
//     });
//   }

//   void _openCart() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const CartPage()),
//     ).then((_) => _loadCartCount());
//   }

//   void _openProductDetails(ProductResponse product) {
//     debugPrint('Tapped product → ${product.name}, id: ${product.id}');
//     // TODO: Navigate to Product Details
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.categoryName),
//         centerTitle: true,
//         backgroundColor: Colors.green,
//         actions: [
//           Stack(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.shopping_cart),
//                 onPressed: _openCart,
//               ),
//               if (_cartCount > 0)
//                 Positioned(
//                   right: 6,
//                   top: 6,
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     constraints: const BoxConstraints(
//                       minWidth: 18,
//                       minHeight: 18,
//                     ),
//                     child: Text(
//                       _cartCount.toString(),
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await _fetchProducts();
//           await _loadCartCount();
//         },
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _errorMessage != null
//             ? Center(child: Text(_errorMessage!))
//             : _products.isEmpty
//             ? const Center(child: Text("No products found in this category"))
//             : Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: GridView.builder(
//                   itemCount: _products.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: 0.6,
//                   ),
//                   itemBuilder: (_, index) {
//                     final product = _products[index];
//                     return Card(
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: const BorderRadius.vertical(
//                                 top: Radius.circular(12),
//                               ),
//                               child:
//                                   (product.imageUrls != null &&
//                                       product.imageUrls!.isNotEmpty)
//                                   ? Image.network(
//                                       "${ApiConfig.imgBaseUrl}/${product.imageUrls!.first}",
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (_, __, ___) => Container(
//                                         color: Colors.grey[300],
//                                         child: const Icon(
//                                           Icons.broken_image,
//                                           size: 50,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     )
//                                   : Container(
//                                       color: Colors.grey[300],
//                                       child: const Icon(
//                                         Icons.image,
//                                         size: 50,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   product.name,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   "\$${product.price.toStringAsFixed(2)}",
//                                   style: const TextStyle(
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 if (product.discountPrice != null)
//                                   Text(
//                                     "\$${product.discountPrice!.toStringAsFixed(2)}",
//                                     style: const TextStyle(
//                                       color: Colors.red,
//                                       decoration: TextDecoration.lineThrough,
//                                     ),
//                                   ),
//                                 const SizedBox(height: 8),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       flex:
//                                           5, // slightly more space for Add to Cart
//                                       child: SizedBox(
//                                         height: 40, // consistent height
//                                         child: ElevatedButton(
//                                           onPressed: () => _addToCart(product),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.green,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                           ),
//                                           child: const Icon(
//                                             Icons.shopping_cart,
//                                             size: 25,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       width: 8,
//                                     ), // a bit more space between buttons
//                                     Expanded(
//                                       flex: 5,
//                                       child: SizedBox(
//                                         height: 40,
//                                         child: ElevatedButton(
//                                           onPressed: () => _buyNow(product),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.orange,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                           ),
//                                           child: const Text(
//                                             "Buy",
//                                             style: TextStyle(fontSize: 9),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/cart.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/services/cart_service.dart';
import 'package:multivendor_flutter_app/ui/public/cart_page.dart';

class CategoryProductsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage>
    with TickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _isRefreshing = false;
  List<ProductResponse> _products = [];
  String? _errorMessage;
  int _cartCount = 0;
  Set<int> _addingToCart = {}; // Track which products are being added to cart

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    );
    _fetchProducts();
    _loadCartCount();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    if (!_isRefreshing) {
      setState(() => _isLoading = true);
    }
    _errorMessage = null;

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        setState(() {
          _errorMessage = 'Please login to view products';
          _isLoading = false;
          _isRefreshing = false;
        });
        return;
      }

      final products = await _productService.getProductsByCategory(
        widget.categoryId,
      );
      setState(() {
        _products = products;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load products. Pull to refresh.';
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _loadCartCount() async {
    try {
      final cart = await _cartService.loadCart();
      if (mounted) {
        setState(() {
          _cartCount = cart.items.fold<int>(
            0,
            (sum, item) => sum + item.quantity,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading cart count: $e');
    }
  }

  Future<void> _addToCart(ProductResponse product) async {
    if (_addingToCart.contains(product.id)) return; // Prevent double taps

    setState(() => _addingToCart.add(product.id));

    try {
      final request = CartItemRequest(productId: product.id, quantity: 1);

      await _cartService.addItem(request);
      await _loadCartCount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${product.name} added to cart',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: Colors.white,
              onPressed: _openCart,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add ${product.name} to cart'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _addingToCart.remove(product.id));
      }
    }
  }

  Future<void> _buyNow(ProductResponse product) async {
    await _addToCart(product);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
      ).then((_) => _loadCartCount());
    }
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    ).then((_) => _loadCartCount());
  }

  void _openProductDetails(ProductResponse product) {
    // TODO: Navigate to Product Details
    debugPrint('Navigating to product details: ${product.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: _openCart,
                splashRadius: 24,
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        _cartCount > 99 ? '99+' : _cartCount.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isRefreshing = true);
          await Future.wait([_fetchProducts(), _loadCartCount()]);
        },
        color: Colors.green,
        backgroundColor: Colors.white,
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
            ? _buildErrorState()
            : _products.isEmpty
            ? _buildEmptyState()
            : _buildProductsGrid(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading products...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchProducts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Products Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no products available in ${widget.categoryName} category at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.55,
        ),
        itemBuilder: (context, index) {
          final product = _products[index];
          final isAdding = _addingToCart.contains(product.id);
          final discountPercentage = product.discountPrice != null
              ? ((product.price - product.discountPrice!) / product.price * 100)
                    .round()
              : null;

          return Hero(
            tag: 'product_${product.id}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openProductDetails(product),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image with Discount Badge
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _buildProductImage(product),
                            ),
                          ),
                          if (discountPercentage != null &&
                              discountPercentage > 0)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.shade200.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$discountPercentage% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Product Details
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Price Section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (product.discountPrice != null) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '\$${product.discountPrice!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    onPressed: isAdding
                                        ? null
                                        : () => _addToCart(product),
                                    backgroundColor: Colors.green.shade50,
                                    foregroundColor: Colors.green.shade700,
                                    icon: isAdding
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.green,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 18,
                                          ),
                                    label: isAdding ? '' : 'Cart',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildActionButton(
                                    onPressed: () => _buyNow(product),
                                    backgroundColor: Colors.orange.shade50,
                                    foregroundColor: Colors.orange.shade700,
                                    icon: const Icon(Icons.flash_on, size: 18),
                                    label: 'Buy',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductImage(ProductResponse product) {
    if (product.imageUrls != null && product.imageUrls!.isNotEmpty) {
      return Image.network(
        "${ApiConfig.imgBaseUrl}/${product.imageUrls!.first}",
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
        ),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green.shade300,
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.image_outlined, size: 40, color: Colors.grey.shade400),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    required Widget icon,
    required String label,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (label.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
