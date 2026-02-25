// import 'package:flutter/material.dart';
// import 'package:multivendor_flutter_app/models/product/product_response.dart';
// import 'package:multivendor_flutter_app/services/ProductService.dart';
// import 'package:multivendor_flutter_app/ui/admin/product/product_details.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:multivendor_flutter_app/services/api_config.dart';
// import 'package:multivendor_flutter_app/ui/vendor/vendor_product/product_form.dart';

// class PublicVendorProductList extends StatefulWidget {
//   // final bool isVendorView;
//   final int? vendorId; // optional vendor filter
//   final String? vendorName; // optional vendor name

//   const PublicVendorProductList({
//     super.key,
//     // this.isVendorView = true,
//     this.vendorId,
//     this.vendorName,
//   });

//   @override
//   State<PublicVendorProductList> createState() =>
//       _PublicVendorProductListState();
// }

// class _PublicVendorProductListState extends State<PublicVendorProductList> {
//   final ProductService _productService = ProductService();

//   bool _isLoading = true;
//   List<ProductResponse> _products = [];
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadVendorProducts();
//   }

//   Future<void> _loadVendorProducts({bool silent = false}) async {
//     if (!silent) {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });
//     }

//     try {
//       final products = widget.vendorId != null
//           ? await _productService.getProductsByVendor(widget.vendorId!)
//           : await _productService.getMyProducts();

//       if (!mounted) return;

//       // ✅ Filter out soft-deleted products
//       final filteredProducts = products
//           .where((p) => p.deleted != true)
//           .toList();

//       setState(() {
//         _products = filteredProducts;
//         _isLoading = false;
//       });
//     } catch (_) {
//       if (!mounted) return;

//       setState(() {
//         _products = [];
//         _errorMessage = 'Failed to load products';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _openForm({ProductResponse? product}) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => VendorProductForm(product: product),
//         fullscreenDialog: true,
//       ),
//     );

//     if (result == true && mounted) {
//       _loadVendorProducts(silent: true);
//     }
//   }

//   Color _getStockColor(int qty) {
//     if (qty <= 0) return Colors.red;
//     if (qty <= 5) return Colors.orange;
//     return Colors.green;
//   }

//   String _getStockStatus(int qty) {
//     if (qty <= 0) return 'OUT';
//     if (qty <= 5) return 'LOW';
//     return 'OK';
//   }

//   Future<void> _deleteProduct(ProductResponse product) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete Product'),
//         content: Text('Delete "${product.name}" ?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     setState(() => _isLoading = true);

//     try {
//       await _productService.deleteProduct(product.id);

//       if (!mounted) return;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Product deleted')));

//       await _loadVendorProducts(silent: true);
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Delete failed: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Widget _buildProductCard(ProductResponse product) {
//     final hasDiscount =
//         product.discountPrice != null && product.discountPrice! < product.price;

//     final displayPrice = product.discountPrice ?? product.price;
//     final displayStock = product.stockQuantity ?? 0;
//     final isLowStock = displayStock <= 5;

//     return InkWell(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => ProductDetail(productId: product.id)),
//       ),
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(12),
//                   ),
//                   child: AspectRatio(
//                     aspectRatio: 1,
//                     child: (product.imageUrls?.isNotEmpty ?? false)
//                         ? CachedNetworkImage(
//                             imageUrl:
//                                 "${ApiConfig.imgBaseUrl}/${product.imageUrls!.first}",
//                             fit: BoxFit.cover,
//                             placeholder: (_, __) => Container(
//                               color: Colors.grey[200],
//                               child: const Center(
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                 ),
//                               ),
//                             ),
//                             errorWidget: (_, __, ___) => Container(
//                               color: Colors.grey[200],
//                               child: const Icon(Icons.image_not_supported),
//                             ),
//                           )
//                         : Container(
//                             color: Colors.grey[200],
//                             child: const Icon(Icons.image),
//                           ),
//                   ),
//                 ),
//                 if (isLowStock)
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 3,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _getStockColor(displayStock),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         _getStockStatus(displayStock),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       product.name,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: Colors.deepPurpleAccent,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Text(
//                           '\$${displayPrice.toStringAsFixed(2)}',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: hasDiscount ? Colors.red : Colors.black,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Stock: $displayStock',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: hasDiscount ? Colors.red : Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: displayStock > 0
//                                 ? () {
//                                     // Add to cart logic here
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           '${product.name} added to cart',
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 : null,
//                             icon: const Icon(Icons.shopping_cart, size: 18),
//                             label: const Text("Add to Cart"),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.deepPurple,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: displayStock > 0
//                                 ? () {
//                                     // Buy now logic here
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           'Proceed to buy ${product.name}',
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 : null,
//                             child: const Text("Buy Now"),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orangeAccent,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());
//     if (_errorMessage != null) return Center(child: Text(_errorMessage!));
//     if (_products.isEmpty)
//       return const Center(
//         child: Text(
//           'No products yet',
//           style: TextStyle(fontSize: 16, color: Colors.grey),
//         ),
//       );

//     return RefreshIndicator(
//       onRefresh: () => _loadVendorProducts(silent: true),
//       child: GridView.builder(
//         padding: const EdgeInsets.all(12),
//         itemCount: _products.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: 0.60,
//         ),
//         itemBuilder: (_, index) => _buildProductCard(_products[index]),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.vendorName != null
//               ? "${widget.vendorName} Products (${_products.length})"
//               : "My Products (${_products.length})",
//         ),
//         automaticallyImplyLeading:
//             widget.vendorId != null, // show back button only for vendor view
//         actions: [
//           // if (widget.isVendorView)
//           //   TextButton.icon(
//           //     onPressed: () => _openForm(),
//           //     icon: const Icon(Icons.add, color: Colors.deepPurple),
//           //     label: const Text(
//           //       "Add",
//           //       style: TextStyle(color: Colors.deepPurple),
//           //     ),
//           //   ),
//         ],
//       ),
//       body: _buildBody(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/ui/admin/product/product_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/ui/public/checkout_page.dart';
import 'package:intl/intl.dart';
import 'package:multivendor_flutter_app/ui/public/public_product_details.dart';

class PublicVendorProductList extends StatefulWidget {
  final int? vendorId;
  final String? vendorName;
  final String? vendorImage;

  const PublicVendorProductList({
    super.key,
    this.vendorId,
    this.vendorName,
    this.vendorImage,
  });

  @override
  State<PublicVendorProductList> createState() =>
      _PublicVendorProductListState();
}

class _PublicVendorProductListState extends State<PublicVendorProductList> {
  final ProductService _productService = ProductService();
  bool _isLoading = true;
  List<ProductResponse> _products = [];
  List<ProductResponse> _filteredProducts = [];
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Set<String> _categories = {'All'};
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  // Sorting options
  String _sortBy = 'Popular';
  bool _isGridView = true;
  final List<String> _sortOptions = [
    'Popular',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
  ];

  @override
  void initState() {
    super.initState();
    _loadVendorProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterProducts();
    });
  }

  void _filterProducts() {
    _filteredProducts = _products.where((product) {
      // Apply search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery) ||
          (product.description?.toLowerCase().contains(_searchQuery) ?? false);

      // Apply category filter
      final matchesCategory =
          _selectedCategory == 'All' ||
          (product.categoryName == _selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();

    _sortProducts();
  }

  void _sortProducts() {
    switch (_sortBy) {
      case 'Price: Low to High':
        _filteredProducts.sort((a, b) {
          final priceA = a.discountPrice ?? a.price;
          final priceB = b.discountPrice ?? b.price;
          return priceA.compareTo(priceB);
        });
        break;
      case 'Price: High to Low':
        _filteredProducts.sort((a, b) {
          final priceA = a.discountPrice ?? a.price;
          final priceB = b.discountPrice ?? b.price;
          return priceB.compareTo(priceA);
        });
        break;
      case 'Newest':
        _filteredProducts.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
      default:
        // 'Popular' - default sorting
        break;
    }
  }

  Future<void> _loadVendorProducts({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final products = widget.vendorId != null
          ? await _productService.getProductsByVendor(widget.vendorId!)
          : await _productService.getMyProducts();

      if (!mounted) return;

      // final filteredProducts = products
      //     .where((p) => p.deleted != true && (p.isActive ?? true))
      //     .toList();

      // Extract categories
      // final categories = {'All'};
      // for (var product in filteredProducts) {
      //   if (product.categoryName != null) {
      //     categories.add(product.categoryName!);
      //   }
      // }

      setState(() {
        // _products = filteredProducts;
        // _filteredProducts = filteredProducts;
        // _categories = categories;
        _isLoading = false;
      });

      _filterProducts();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _products = [];
        _filteredProducts = [];
        _errorMessage = 'Failed to load products. Pull down to refresh.';
        _isLoading = false;
      });
    }
  }

  Color _getStockColor(int qty) {
    if (qty <= 0) return Colors.red;
    if (qty <= 5) return Colors.orange;
    return Colors.green;
  }

  String _getStockStatus(int qty) {
    if (qty <= 0) return 'Out of Stock';
    if (qty <= 5) return 'Low Stock';
    return 'In Stock';
  }

  double _getDiscountedPrice(ProductResponse product) {
    return product.discountPrice ?? product.price;
  }

  double _getDiscountPercentage(ProductResponse product) {
    if (product.discountPrice == null ||
        product.discountPrice! >= product.price) {
      return 0;
    }
    return ((product.price - product.discountPrice!) / product.price * 100)
        .roundToDouble();
  }

  Widget _buildProductCard(ProductResponse product) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;
    final displayPrice = _getDiscountedPrice(product);
    final displayStock = product.stockQuantity ?? 0;
    final isInStock = displayStock > 0;
    final discountPercentage = _getDiscountPercentage(product);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image with badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: (product.imageUrls?.isNotEmpty ?? false)
                      ? CachedNetworkImage(
                          imageUrl:
                              "${ApiConfig.imgBaseUrl}/${product.imageUrls!.first}",
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepPurple,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[100],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                ),
              ),

              // Discount badge
              if (hasDiscount)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '-${discountPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Stock badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isInStock
                        ? _getStockColor(displayStock).withOpacity(0.9)
                        : Colors.grey.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isInStock
                                    ? _getStockColor(displayStock)
                                    : Colors.grey)
                                .withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getStockStatus(displayStock),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Favorite button
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      // TODO: Add to wishlist
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to wishlist'),
                          backgroundColor: Colors.deepPurple,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),

          // Product info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 4),

                // Category
                if (product.categoryName != null)
                  Text(
                    product.categoryName!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 8),

                // Price
                Row(
                  children: [
                    Text(
                      _currencyFormat.format(displayPrice),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasDiscount ? Colors.red : Colors.deepPurple,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        _currencyFormat.format(product.price),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    // Add to cart button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isInStock
                            ? () {
                                // TODO: Add to cart logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product.name} added to cart',
                                    ),
                                    backgroundColor: Colors.deepPurple,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInStock
                              ? Colors.deepPurple
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Icon(Icons.shopping_cart, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Buy now button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isInStock
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CheckoutPage(cartItems: [product]),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInStock
                              ? Colors.orange
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Buy',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(ProductResponse product) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;
    final displayPrice = _getDiscountedPrice(product);
    final displayStock = product.stockQuantity ?? 0;
    final isInStock = displayStock > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to product details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PublicProductDetailsPage(productId: product.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Container(
                width: 120,
                height: 120,
                color: Colors.grey[100],
                child: (product.imageUrls?.isNotEmpty ?? false)
                    ? CachedNetworkImage(
                        imageUrl:
                            "${ApiConfig.imgBaseUrl}/${product.imageUrls!.first}",
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),

            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Category
                    if (product.categoryName != null)
                      Text(
                        product.categoryName!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),

                    const SizedBox(height: 8),

                    // Price
                    Row(
                      children: [
                        Text(
                          _currencyFormat.format(displayPrice),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: hasDiscount ? Colors.red : Colors.deepPurple,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 8),
                          Text(
                            _currencyFormat.format(product.price),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Stock status
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isInStock
                                ? _getStockColor(displayStock)
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStockStatus(displayStock),
                          style: TextStyle(
                            fontSize: 12,
                            color: isInStock
                                ? _getStockColor(displayStock)
                                : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isInStock ? () {} : null,
                            icon: const Icon(Icons.shopping_cart, size: 16),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInStock
                                  ? Colors.deepPurple
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 32),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isInStock ? () {} : null,
                            child: const Text('Buy'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInStock
                                  ? Colors.orange
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 32),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Categories horizontal scroll
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterProducts();
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: Colors.deepPurple.withOpacity(0.1),
                    checkmarkColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.deepPurple : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.transparent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Sort and view toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                // Sort dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _sortBy = newValue;
                          _sortProducts();
                        });
                      }
                    },
                    items: _sortOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    underline: const SizedBox(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.deepPurple,
                    ),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),

                const Spacer(),

                // View toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _buildViewToggleButton(Icons.grid_view, true),
                      _buildViewToggleButton(Icons.list, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(IconData icon, bool isGrid) {
    final isSelected = _isGridView == isGrid;
    return InkWell(
      onTap: () {
        setState(() {
          _isGridView = isGrid;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            SizedBox(height: 16),
            Text('Loading products...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadVendorProducts(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new products',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadVendorProducts(silent: true),
      color: Colors.deepPurple,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Vendor header
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.vendorName != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          if (widget.vendorImage != null)
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                "${ApiConfig.imgBaseUrl}/${widget.vendorImage}",
                              ),
                              radius: 24,
                            ),
                          if (widget.vendorImage != null)
                            const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.vendorName!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_filteredProducts.length} products available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildFilters(),
                ],
              ),
            ),
          ),

          // Products grid/list
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _isGridView
                ? SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildProductCard(_filteredProducts[index]),
                      childCount: _filteredProducts.length,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildProductListItem(_filteredProducts[index]),
                      childCount: _filteredProducts.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.vendorName ?? 'Products',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (_filteredProducts.isNotEmpty)
              Text(
                '${_filteredProducts.length} items',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          // Shopping cart
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  // TODO: Navigate to cart
                },
              ),
              // Cart badge
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
