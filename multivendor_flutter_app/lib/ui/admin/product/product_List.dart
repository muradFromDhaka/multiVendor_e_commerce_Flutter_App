import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/ui/admin/product/product_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

import 'package:multivendor_flutter_app/ui/admin/product/product_form.dart';

class ProductList extends StatefulWidget {
  final bool isVendorView; // To show vendor-specific products
  final int? categoryId; // For category-specific filtering
  final int? brandId; // For brand-specific filtering
  final String? title; // Custom title

  const ProductList({
    super.key,
    this.isVendorView = false,
    this.categoryId,
    this.brandId,
    this.title,
  });

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  // Pagination
  static const int _pageSize = 20;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;

  // Data
  List<ProductResponse> _products = [];
  List<ProductResponse> _filteredProducts = [];
  String? _errorMessage;

  // Filter states
  String _searchQuery = '';
  String _selectedSort = 'Newest';
  RangeValues _priceRange = const RangeValues(0, 100000);
  double _maxPrice = 100000;
  bool _showFilters = false;
  bool _isSearching = false;

  // Categories from API (would be fetched)
  final List<String> _categories = ['All'];
  String _selectedCategory = 'All';

  // Sort options
  final List<String> _sortOptions = [
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
    'Popularity',
    'Top Rated',
    'Most Sold',
  ];

  // Animation
  late AnimationController _animationController;
  late Animation<double> _filterAnimation;

  // Debounce for search
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _setupAnimations();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _filterAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreProducts();
    }
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim();
        });
        _filterProducts();
      }
    });
  }

  Future<void> _loadProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    try {
      List<ProductResponse> products;

      // Load products based on context
      if (widget.isVendorView) {
        products = await _productService.getMyProducts();
      } else if (widget.categoryId != null) {
        products = await _productService.getProductsByCategory(
          widget.categoryId!,
        );
      } else if (widget.brandId != null) {
        products = await _productService.getProductsByBrand(widget.brandId!);
      } else {
        products = await _productService.getAllProducts();
      }

      if (!mounted) return;

      // Calculate max price for filter
      double maxPrice = 0;
      for (var product in products) {
        final price = product.discountPrice ?? product.price;
        if (price > maxPrice) maxPrice = price;
      }

      // Extract unique categories
      final Set<String> categories = {'All'};
      for (var product in products) {
        if (product.categoryName != null) {
          categories.add(product.categoryName!);
        }
      }

      setState(() {
        _products = products;
        _filteredProducts = products;
        _categories.clear();
        _categories.addAll(categories);
        _maxPrice = maxPrice > 0 ? maxPrice : 100000;
        _priceRange = RangeValues(0, _maxPrice);
        _isLoading = false;
        _hasMore = products.length >= _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _getUserFriendlyError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      List<ProductResponse> moreProducts;

      if (widget.isVendorView) {
        moreProducts = await _productService.getMyProducts();
      } else if (_searchQuery.isNotEmpty) {
        moreProducts = await _productService.searchProducts(_searchQuery);
      } else {
        moreProducts = await _productService.getAllProducts();
      }

      if (!mounted) return;

      setState(() {
        _products.addAll(moreProducts);
        _filterProducts(); // Re-apply filters
        _hasMore = moreProducts.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar('Failed to load more products');
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          final nameMatch = product.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final descMatch =
              product.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false;
          final skuMatch = product.sku.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          if (!nameMatch && !descMatch && !skuMatch) return false;
        }

        // Apply category filter
        if (_selectedCategory != 'All' &&
            product.categoryName != _selectedCategory) {
          return false;
        }

        // Apply price filter
        final effectivePrice = product.discountPrice ?? product.price;
        if (effectivePrice < _priceRange.start ||
            effectivePrice > _priceRange.end) {
          return false;
        }

        return true;
      }).toList();

      // Apply sorting
      _sortProducts();
    });
  }

  void _sortProducts() {
    switch (_selectedSort) {
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
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
      case 'Popularity':
        _filteredProducts.sort(
          (a, b) => (b.soldCount ?? 0).compareTo(a.soldCount ?? 0),
        );
        break;
      case 'Top Rated':
        _filteredProducts.sort(
          (a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0),
        );
        break;
      case 'Most Sold':
        _filteredProducts.sort(
          (a, b) => (b.soldCount ?? 0).compareTo(a.soldCount ?? 0),
        );
        break;
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('socket') || errorStr.contains('network')) {
      return 'No internet connection. Please check your network.';
    } else if (errorStr.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'You don\'t have permission to view products.';
    } else if (errorStr.contains('404')) {
      return 'Products not found.';
    } else {
      return 'Failed to load products. Pull to refresh.';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadProducts,
        ),
      ),
    );
  }

  Future<void> _deleteProduct(ProductResponse product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _productService.deleteProduct(product.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} deleted successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _loadProducts();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to delete product: ${e.toString()}');
    }
  }

  Future<void> _openForm({ProductResponse? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductForm(product: product),
        fullscreenDialog: true,
      ),
    );

    if (result == true && mounted) {
      _loadProducts();
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedSort = 'Newest';
      _priceRange = RangeValues(0, _maxPrice);
      _searchController.clear();
      _searchQuery = '';
    });
    _filterProducts();
  }

  String _getStockStatus(int quantity) {
    if (quantity <= 0) return 'Out of Stock';
    if (quantity <= 5) return 'Only $quantity left';
    if (quantity <= 20) return 'Low Stock';
    return 'In Stock';
  }

  Color _getStockColor(int quantity) {
    if (quantity <= 0) return Colors.red;
    if (quantity <= 5) return Colors.orange;
    if (quantity <= 20) return Colors.amber;
    return Colors.green;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search by name, description or SKU...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _searchQuery = '';
                            _filterProducts();
                          },
                        )
                      : null,
                ),
                style: const TextStyle(fontSize: 16),
                autofocus: true,
              )
            : Text(
                widget.title ??
                    (widget.isVendorView ? 'My Products' : 'Products'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _searchFocusNode.unfocus();
                  _filterProducts();
                } else {
                  _searchFocusNode.requestFocus();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _toggleFilters,
          ),
          if (!widget.isVendorView)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _openForm(),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            // Active filters chips
            if (_products.isNotEmpty && !_isLoading) _buildActiveFilters(),

            // Filter panel
            if (_showFilters)
              SizeTransition(
                sizeFactor: _filterAnimation,
                child: _buildFilterPanel(),
              ),

            // Main content
            Expanded(
              child: _isLoading
                  ? _buildLoadingShimmer()
                  : _errorMessage != null
                  ? _buildErrorView()
                  : _filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : _buildProductGrid(),
            ),

            // Loading more indicator
            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      floatingActionButton: _products.isNotEmpty && !widget.isVendorView
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              label: const Text('Add Product'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildActiveFilters() {
    final activeFilters = <String>[];
    if (_selectedCategory != 'All') {
      activeFilters.add('Category: $_selectedCategory');
    }
    if (_selectedSort != 'Newest') {
      activeFilters.add('Sort: $_selectedSort');
    }
    if (_priceRange.start > 0 || _priceRange.end < _maxPrice) {
      activeFilters.add(
        'Price: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
      );
    }
    if (_searchQuery.isNotEmpty) {
      activeFilters.add('Search: "$_searchQuery"');
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...activeFilters.map(
            (filter) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(filter, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  if (filter.startsWith('Category:')) {
                    setState(() => _selectedCategory = 'All');
                  } else if (filter.startsWith('Sort:')) {
                    setState(() => _selectedSort = 'Newest');
                  } else if (filter.startsWith('Price:')) {
                    setState(() => _priceRange = RangeValues(0, _maxPrice));
                  } else if (filter.startsWith('Search:')) {
                    _searchController.clear();
                    _searchQuery = '';
                  }
                  _filterProducts();
                },
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
          if (activeFilters.length > 1)
            TextButton(
              onPressed: _resetFilters,
              child: const Text('Clear All'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleFilters,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _filterProducts();
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Sort
          const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sortOptions.map((sort) {
              return ChoiceChip(
                label: Text(sort),
                selected: _selectedSort == sort,
                onSelected: (_) {
                  setState(() {
                    _selectedSort = sort;
                  });
                  _filterProducts();
                },
                backgroundColor: Colors.grey[100],
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: _selectedSort == sort
                      ? Theme.of(context).primaryColor
                      : Colors.black,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Price Range
          const Text(
            'Price Range',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: _maxPrice,
            divisions: 20,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
            onChangeEnd: (_) => _filterProducts(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_priceRange.start.round()}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '\$${_priceRange.end.round()}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _toggleFilters();
                _filterProducts();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.53,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductResponse product) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;
    final discountPercentage = hasDiscount
        ? ((product.price - product.discountPrice!) / product.price * 100)
              .round()
        : 0;
    final displayPrice = product.discountPrice ?? product.price;
    final isLowStock = product.stockQuantity <= 5;
    final isOutOfStock = product.stockQuantity <= 0;

    return Hero(
      tag: 'product-${product.id}',
      child: Material(
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetail(productId: product.id),
            ),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
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
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
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
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-$discountPercentage%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Stock status badge
                    if (isLowStock || isOutOfStock)
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Product details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand/Category
                        if (product.brandName != null ||
                            product.categoryName != null)
                          Text(
                            product.brandName ?? product.categoryName ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 2),

                        // Product name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Rating
                        if (product.averageRating != null)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.averageRating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (product.totalReviews != null)
                                Text(
                                  '(${product.totalReviews})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),

                        const SizedBox(height: 4),

                        // Price
                        Row(
                          children: [
                            Text(
                              '\$${displayPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: hasDiscount ? Colors.red : Colors.black,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 4),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // SKU (optional, for admin view)
                        if (widget.isVendorView)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'SKU: ${product.sku}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        const Spacer(),

                        // Sold count
                        if (product.soldCount != null && product.soldCount! > 0)
                          Text(
                            '${product.soldCount} sold',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),

                        const SizedBox(height: 4),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.blue,
                              ),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              onPressed: () => _openForm(product: product),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red,
                              ),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              onPressed: () => _deleteProduct(product),
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
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 14,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(width: 80, height: 20, color: Colors.grey[300]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
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
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'No Results Found' : 'No Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No products match "$_searchQuery"'
                  : widget.isVendorView
                  ? 'You haven\'t added any products yet'
                  : 'No products available at the moment',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (!widget.isVendorView && _searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Product'),
              ),
            ],
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _searchQuery = '';
                  _filterProducts();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
