import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multivendor_flutter_app/ui/public/public_product_zoom.dart';
import 'package:shimmer/shimmer.dart';

class PublicProductDetailsPage extends StatefulWidget {
  final int productId;

  const PublicProductDetailsPage({super.key, required this.productId});

  @override
  State<PublicProductDetailsPage> createState() =>
      _PublicProductDetailsPageState();
}

class _PublicProductDetailsPageState extends State<PublicProductDetailsPage>
    with TickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  ProductResponse? _product;
  bool _isLoading = true;
  bool _isAddingToCart = false;
  bool _isBuyingNow = false;
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  bool _isExpanded = false;
  int _selectedQuantity = 1;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _buttonAnimationController;

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

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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
        _showSnackBar(
          "Failed to load product. Please try again.",
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 3),
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

  Future<void> _addToCart() async {
    if (_product == null) return;

    setState(() => _isAddingToCart = true);
    _buttonAnimationController.forward();

    // Simulate API call - replace with actual add to cart logic
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isAddingToCart = false);
    _buttonAnimationController.reverse();

    _showSnackBar('${_product!.name} added to cart');
  }

  Future<void> _buyNow() async {
    if (_product == null) return;

    setState(() => _isBuyingNow = true);
    _buttonAnimationController.forward();

    // Simulate API call - replace with actual buy now logic
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isBuyingNow = false);
    _buttonAnimationController.reverse();

    // Navigate to checkout page
    _showSnackBar('Proceeding to checkout...');
  }

  void _shareProduct() {
    _showSnackBar('Share feature coming soon!');
  }

  void _incrementQuantity() {
    if (_selectedQuantity < 10) {
      setState(() {
        _selectedQuantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_selectedQuantity > 1) {
      setState(() {
        _selectedQuantity--;
      });
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
    _buttonAnimationController.dispose();
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            // Favorite button
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
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
                    _isFavorite ? 'Added to wishlist' : 'Removed from wishlist',
                  );
                },
              ),
            ),
            // Share button
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.black87),
                onPressed: _shareProduct,
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
                    _buildQuantitySelector(),
                    _buildDivider(),
                    _buildProductInfo(),
                    _buildDivider(),
                    _buildDescription(),
                    _buildDivider(),
                    _buildSpecifications(),
                    _buildDivider(),
                    _buildSellerInfo(),
                    _buildDivider(),
                    _buildDeliveryInfo(),
                    _buildDivider(),
                    _buildCustomerReviews(),
                    const SizedBox(height: 80),
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
                    builder: (_) => PublicProductZoomPage(
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
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and Brand chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_product!.categoryName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.category, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        _product!.categoryName!,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_product!.brandName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.business,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _product!.brandName!,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _product!.stockQuantity > 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _product!.stockQuantity > 0
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 14,
                      color: _product!.stockQuantity > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _product!.stockQuantity > 0
                          ? _product!.stockQuantity <= 5
                                ? 'Only ${_product!.stockQuantity} left'
                                : 'In Stock'
                          : 'Out of Stock',
                      style: TextStyle(
                        color: _product!.stockQuantity > 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Product name
          Text(
            _product!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // SKU and Rating row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'SKU: ${_product!.sku}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 12),
              if (_product!.averageRating != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Text(
                        _product!.averageRating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (_product!.totalReviews != null)
                        Text(
                          '(${_product!.totalReviews} reviews)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasDiscount) ...[
            Text(
              '\$${_product!.discountPrice!.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${_product!.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
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
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    final unitPrice = (_product!.discountPrice ?? _product!.price);
    final totalPrice = unitPrice * _selectedQuantity;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Quantity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: _decrementQuantity,
                    ),
                    SizedBox(
                      width: 35,
                      child: Text(
                        '$_selectedQuantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: _incrementQuantity,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              if (_product!.stockQuantity != null)
                Text(
                  '${_product!.stockQuantity} available',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
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
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
            children: [
              _buildInfoCard(
                icon: Icons.inventory_2,
                label: 'Stock',
                value: '${_product!.stockQuantity} units',
                color: Colors.blue,
              ),
              if (_product!.soldCount != null)
                _buildInfoCard(
                  icon: Icons.shopping_bag,
                  label: 'Sold',
                  value: '${_product!.soldCount}',
                  color: Colors.green,
                ),
              if (_product!.releaseDate != null)
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  label: 'Release',
                  value: _formatDate(_product!.releaseDate),
                  color: Colors.orange,
                ),
              if (_product!.createdAt != null)
                _buildInfoCard(
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              _product!.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.6,
              ),
              maxLines: _isExpanded ? null : 4,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),
          ),
          if (_product!.description!.length > 200)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(_isExpanded ? 'Show Less' : 'Read More'),
              ),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
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
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seller Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store, color: Colors.blue, size: 30),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified Seller',
                            style: TextStyle(fontSize: 13, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Member since ${_formatDate(_product!.createdAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to seller page
                    _showSnackBar('Viewing seller store');
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Visit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildDeliveryRow(
                  icon: Icons.local_shipping,
                  title: 'Free Shipping',
                  subtitle: 'On orders over \$50',
                ),
                const Divider(height: 16),
                _buildDeliveryRow(
                  icon: Icons.timer,
                  title: 'Estimated Delivery',
                  subtitle: '3-5 business days',
                ),
                const Divider(height: 16),
                _buildDeliveryRow(
                  icon: Icons.assignment_return,
                  title: 'Easy Returns',
                  subtitle: '7 days return policy',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerReviews() {
    if (_product!.averageRating == null || _product!.totalReviews == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  _showSnackBar('View all reviews');
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _product!.averageRating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const Text(
                          'out of 5',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_product!.totalReviews} ratings',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const Icon(
                            Icons.star_half,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on ${_product!.totalReviews} reviews',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
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
              child: Icon(
                Icons.shopping_cart,
                size: 40,
                color: const Color.fromARGB(255, 155, 127, 127),
              ),
            ),
            const SizedBox(width: 8),
            // Add to cart button
            Expanded(
              flex: 3,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1, end: 0.95).animate(
                  CurvedAnimation(
                    parent: _buttonAnimationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isAddingToCart || _isBuyingNow
                      ? null
                      : _addToCart,
                  icon: _isAddingToCart
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.shopping_cart),
                  label: Text(_isAddingToCart ? 'Adding...' : 'Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Buy now button
            Expanded(
              flex: 2,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1, end: 0.95).animate(
                  CurvedAnimation(
                    parent: _buttonAnimationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _isAddingToCart || _isBuyingNow ? null : _buyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isBuyingNow
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Buy Now'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.grey[200], thickness: 1),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 300, color: Colors.white),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 150, height: 20, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 20, color: Colors.white),
                  const SizedBox(height: 20),
                  Container(width: 250, height: 40, color: Colors.white),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The product you\'re looking for doesn\'t exist or has been removed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
