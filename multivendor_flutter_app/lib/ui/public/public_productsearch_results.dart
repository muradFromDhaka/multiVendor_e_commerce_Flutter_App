import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// Search Results Page
class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final ProductService _productService = ProductService();
  List<ProductResponse> _searchResults = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _performSearch();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreResults();
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    try {
      final results = await _productService.searchProducts(widget.query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
        _hasMore = results.length >= 20;
      });
    } catch (e) {
      setState(() {
        _errorMessage = _getUserFriendlyError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final moreResults = await _productService.searchProducts(widget.query);

      setState(() {
        _searchResults.addAll(moreResults);
        _isLoadingMore = false;
        _hasMore = moreResults.length >= 20;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar('Failed to load more results');
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socket') || errorString.contains('network')) {
      return 'No internet connection. Please check your network.';
    } else if (errorString.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else {
      return 'Failed to load search results.';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addToCart(ProductResponse product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _buyNow(ProductResponse product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing order for ${product.name}'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search: "${widget.query}"'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingShimmer()
          : _errorMessage != null
          ? _buildErrorView()
          : _searchResults.isEmpty
          ? _buildEmptyView()
          : _buildResultsGrid(),
    );
  }

  Widget _buildResultsGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: _searchResults.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _searchResults.length) {
          return _buildLoadingMoreIndicator();
        }
        return _buildSearchResultCard(_searchResults[index]);
      },
    );
  }

  Widget _buildSearchResultCard(ProductResponse product) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;
    final displayPrice = product.discountPrice ?? product.price;

    return GestureDetector(
      onTap: () {
        // Navigate to product detail
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewing ${product.name}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
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
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: product.imageUrls?.isNotEmpty ?? false
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
                                Icons.image,
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
                        '-${((product.price - product.discountPrice!) / product.price * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.averageRating != null)
                      Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.amber[600]),
                          const SizedBox(width: 2),
                          Text(
                            product.averageRating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                          if (product.totalReviews != null)
                            Text(
                              '(${product.totalReviews})',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${displayPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hasDiscount ? Colors.red : Colors.black,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 4),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _addToCart(product),
                            icon: const Icon(Icons.add_shopping_cart, size: 14),
                            label: const Text(
                              'Cart',
                              style: TextStyle(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _buyNow(product),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Buy',
                              style: TextStyle(fontSize: 11),
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

  Widget _buildLoadingMoreIndicator() {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
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
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
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
                          height: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(width: 100, height: 10, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 80, height: 20, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
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
              onPressed: _performSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
