import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/ui/admin/product/image_zoom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multivendor_flutter_app/ui/admin/product/test_product_form.dart';
import 'product_form.dart';

class ProductDetail extends StatefulWidget {
  final int productId;

  const ProductDetail({super.key, required this.productId});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  ProductResponse? _product;
  bool _isLoading = true;
  bool _isDeleting = false;
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadProduct();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final product = await _productService.getProductById(widget.productId);
      setState(() => _product = product);
    } catch (e) {
      debugPrint("Error fetching product: $e");
      if (mounted) {
        _showSnackBar("Failed to load product: ${e.toString()}", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: isError
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _loadProduct,
              )
            : null,
      ),
    );
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete '${_product?.name}'?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await _productService.deleteProduct(widget.productId);
      if (mounted) {
        _showSnackBar("Product deleted successfully");
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Delete failed: $e");
      if (mounted) {
        _showSnackBar("Delete failed: ${e.toString()}", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? _buildLoadingShimmer()
          : _product == null
          ? _buildErrorView()
          : _buildProductContent(),
      bottomNavigationBar: _product != null && !_isLoading
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildProductContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Custom App Bar with image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          stretch: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.black87,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  _showSnackBar(
                    _isFavorite
                        ? 'Added to favorites'
                        : 'Removed from favorites',
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductForm(product: _product),
                      ),
                    );
                    if (updated == true) _loadProduct();
                  } else if (value == 'delete') {
                    _deleteProduct();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit Product'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Product'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(background: _buildImageSlider()),
        ),

        // Product Details
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildPriceSection(),
                    _buildDivider(),
                    _buildProductInfo(),
                    _buildDivider(),
                    _buildDescription(),
                    _buildDivider(),
                    _buildSpecifications(),
                    _buildDivider(),
                    _buildSellerInfo(),
                    const SizedBox(height: 80), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSlider() {
    if (_product!.imageUrls == null || _product!.imageUrls!.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 80, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _product!.imageUrls!.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final url = _product!.imageUrls![index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImageZoomPage(
                      imageUrls: _product!.imageUrls!
                          .map((e) => "${ApiConfig.imgBaseUrl}/$e")
                          .toList(),
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: "${ApiConfig.imgBaseUrl}/$url",
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
            );
          },
        ),

        // Image counter
        if (_product!.imageUrls!.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${_product!.imageUrls!.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Image indicators
        if (_product!.imageUrls!.length > 1)
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: List.generate(
                _product!.imageUrls!.length,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    final hasDiscount =
        _product!.discountPrice != null &&
        _product!.discountPrice! < _product!.price;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and Brand chips
          Wrap(
            spacing: 8,
            children: [
              if (_product!.categoryName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _product!.categoryName!,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (_product!.brandName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _product!.brandName!,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _product!.stockQuantity > 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _product!.stockQuantity > 0 ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                    color: _product!.stockQuantity > 0
                        ? Colors.green
                        : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Product name
          Text(
            _product!.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // SKU and Rating row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SKU: ${_product!.sku}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 12),
              if (_product!.averageRating != null) ...[
                Icon(Icons.star, size: 16, color: Colors.amber[600]),
                const SizedBox(width: 4),
                Text(
                  _product!.averageRating!.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                if (_product!.totalReviews != null)
                  Text(
                    '(${_product!.totalReviews} reviews)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final hasDiscount =
        _product!.discountPrice != null &&
        _product!.discountPrice! < _product!.price;
    final discountPercentage = hasDiscount
        ? ((_product!.price - _product!.discountPrice!) / _product!.price * 100)
              .round()
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasDiscount) ...[
            Text(
              '\$${_product!.discountPrice!.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${_product!.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-$discountPercentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ] else ...[
            Text(
              '\$${_product!.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildInfoChip(
                icon: Icons.inventory_2,
                label: 'Stock',
                value: '${_product!.stockQuantity} units',
                color: Colors.blue,
              ),
              if (_product!.soldCount != null)
                _buildInfoChip(
                  icon: Icons.shopping_bag,
                  label: 'Sold',
                  value: '${_product!.soldCount}',
                  color: Colors.green,
                ),
              if (_product!.releaseDate != null)
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: 'Release',
                  value: _formatDate(_product!.releaseDate),
                  color: Colors.orange,
                ),
              if (_product!.createdAt != null)
                _buildInfoChip(
                  icon: Icons.add_circle,
                  label: 'Created',
                  value: _formatDate(_product!.createdAt),
                  color: Colors.purple,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (_product!.description == null || _product!.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _product!.description!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
            maxLines: _isExpanded ? null : 3,
            overflow: _isExpanded ? null : TextOverflow.ellipsis,
          ),
          if (_product!.description!.length > 150)
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(_isExpanded ? 'Show Less' : 'Read More'),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecifications() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSpecRow('Product ID', '#${_product!.id}'),
          _buildSpecRow('SKU', _product!.sku),
          if (_product!.categoryName != null)
            _buildSpecRow('Category', _product!.categoryName!),
          if (_product!.brandName != null)
            _buildSpecRow('Brand', _product!.brandName!),
          if (_product!.vendorName != null)
            _buildSpecRow('Vendor', _product!.vendorName!),
          if (_product!.status != null)
            _buildSpecRow('Status', _product!.status!),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    if (_product!.vendorName == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.store, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product!.vendorName!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Verified Seller',
                  style: TextStyle(fontSize: 13, color: Colors.green),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // Navigate to seller page
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Visit Store'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: OutlinedButton.icon(
                onPressed: _isDeleting ? null : () => _openForm(),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isDeleting ? null : _deleteProduct,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete),
                label: Text(_isDeleting ? 'Deleting...' : 'Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openForm() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductForm(product: _product)),
    );
    if (updated == true) _loadProduct();
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.grey[200], thickness: 1),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(height: 300, color: Colors.grey[300]),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 20, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 30,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(width: 150, height: 20, color: Colors.grey[300]),
                const SizedBox(height: 20),
                Container(width: 200, height: 40, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Product Not Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The product you\'re looking for doesn\'t exist or has been removed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
