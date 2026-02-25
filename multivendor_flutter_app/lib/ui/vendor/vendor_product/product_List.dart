import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/ui/admin/product/product_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/ui/vendor/vendor_product/product_form.dart';

class VendorProductList extends StatefulWidget {
  final bool isVendorView;

  const VendorProductList({super.key, this.isVendorView = true});

  @override
  State<VendorProductList> createState() => _VendorProductListState();
}

class _VendorProductListState extends State<VendorProductList> {
  final ProductService _productService = ProductService();

  bool _isLoading = true;
  List<ProductResponse> _products = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVendorProducts();
  }

  Future<void> _loadVendorProducts({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final products = await _productService.getMyProducts();

      if (!mounted) return;

      // ✅ Filter out soft-deleted products
      final filteredProducts = products
          .where((p) => p.deleted != true)
          .toList();

      setState(() {
        _products = filteredProducts;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _products = [];
        _errorMessage = 'Failed to load your products';
        _isLoading = false;
      });
    }
  }

  Future<void> _openForm({ProductResponse? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VendorProductForm(product: product),
        fullscreenDialog: true,
      ),
    );

    if (result == true && mounted) {
      _loadVendorProducts(silent: true);
    }
  }

  Color _getStockColor(int qty) {
    if (qty <= 0) return Colors.red;
    if (qty <= 5) return Colors.orange;
    return Colors.green;
  }

  String _getStockStatus(int qty) {
    if (qty <= 0) return 'OUT';
    if (qty <= 5) return 'LOW';
    return 'OK';
  }

  Future<void> _deleteProduct(ProductResponse product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await _productService.deleteProduct(product.id);

      if (!mounted) return;

      // Only show snackbar if delete succeeded
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product deleted')));

      // Refresh list
      await _loadVendorProducts(silent: true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildProductCard(ProductResponse product) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;

    final displayPrice = product.discountPrice ?? product.price;
    final displayStack = product.stockQuantity ?? product.stockQuantity;

    final isLowStock = product.stockQuantity <= 5;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetail(productId: product.id)),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: (product.imageUrls?.isNotEmpty ?? false)
                        ? CachedNetworkImage(
                            imageUrl:
                                "${ApiConfig.imgBaseUrl}/${product.imageUrls!.first}",
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image),
                          ),
                  ),
                ),
                if (isLowStock)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getStockColor(product.stockQuantity),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStockStatus(product.stockQuantity),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${displayPrice}, ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: hasDiscount ? Colors.red : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stock: ${displayStack}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: hasDiscount ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _openForm(product: product),
                            child: const Text("Edit"),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => _deleteProduct(product),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text(
          'No products yet',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadVendorProducts(silent: true),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.60,
        ),
        itemBuilder: (_, index) => _buildProductCard(_products[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Products (${_products.length})'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add, color: Colors.deepPurple),
            label: const Text(
              "Add",
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
