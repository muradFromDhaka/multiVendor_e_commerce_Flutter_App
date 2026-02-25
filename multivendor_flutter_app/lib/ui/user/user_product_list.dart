import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:multivendor_flutter_app/core/network/api_exceptions.dart';
import 'package:multivendor_flutter_app/models/cart.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/services/cart_service.dart';
import 'package:multivendor_flutter_app/services/category_service.dart';
import 'package:multivendor_flutter_app/services/vendor_service.dart';
import 'package:multivendor_flutter_app/ui/auth/login_page.dart';
import 'package:multivendor_flutter_app/ui/public/cart_page.dart';
import 'package:multivendor_flutter_app/ui/public/public_category_page.dart';
import 'package:multivendor_flutter_app/ui/public/public_drawer.dart';
import 'package:multivendor_flutter_app/ui/public/public_product_details.dart';
import 'package:multivendor_flutter_app/ui/public/public_productsearch_results.dart';
import 'package:multivendor_flutter_app/ui/public/public_vendorproduct.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/models/category/category_response.dart';
import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class UserProductListPage extends StatefulWidget {
  const UserProductListPage({super.key});

  @override
  State<UserProductListPage> createState() => _UserProductListPageState();
}

class _UserProductListPageState extends State<UserProductListPage>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final VendorService _vendorService = VendorService();
  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  // Search suggestions
  Timer? _debounceTimer;
  CartDto? cart;
  List<ProductResponse> _searchSuggestions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  // Data lists
  List<ProductResponse> _latestProducts = [];
  List<ProductResponse> _trendingProducts = [];
  List<ProductResponse> _discountedProducts = [];
  List<ProductResponse> _featuredProducts = [];
  List<CategoryResponse> _categories = [];
  List<dynamic> _vendors = [];

  // Vendor products map
  Map<int, List<ProductResponse>> _vendorProducts = {};

  // Timer for auto scroll
  Timer? _autoScrollTimer;

  // User interaction tracking
  bool _isUserInteracting = false;

  // Loading states
  bool _isLoading = true;
  bool _isLoadingVendorProducts = false;
  String? _errorMessage;

  // Hero section banners
  final List<String> _bannerImages = [
    'assets/banners/img.jpg',
    'assets/banners/img2.jpg',
    'assets/banners/img3.jpg',
    'assets/banners/img4.jpg',
    'assets/banners/img6.jpg',
  ];

  int _currentBannerIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadHomePageData();
    _setupAnimations();
    _startAutoScroll();
    _searchController.addListener(_onSearchChanged);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  // Auto scroll function
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isUserInteracting &&
          _pageController.hasClients &&
          _bannerImages.isNotEmpty) {
        final nextPage = (_currentBannerIndex + 1) % _bannerImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // User interaction handlers
  void _handleUserInteractionStart() {
    setState(() {
      _isUserInteracting = true;
    });
  }

  void _handleUserInteractionEnd() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
        });
      }
    });
  }

  // Search functionality
  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _fetchSearchSuggestions(_searchController.text);
      } else {
        _hideSuggestions();
      }
    });
  }

  Future<void> _fetchSearchSuggestions(String query) async {
    try {
      final results = await _productService.searchProducts(query);
      if (mounted) {
        setState(() {
          _searchSuggestions = results.take(5).toList();
        });
        _showSuggestions();
      }
    } catch (e) {
      debugPrint('Search suggestion error: $e');
    }
  }

  void _showSuggestions() {
    _overlayEntry?.remove();

    if (_searchSuggestions.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 45),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchSuggestions.length,
                itemBuilder: (context, index) {
                  final product = _searchSuggestions[index];
                  return ListTile(
                    leading: product.imageUrls?.isNotEmpty ?? false
                        ? CachedNetworkImage(
                            imageUrl:
                                "${ApiConfig.imgBaseUrl}/${product.imageUrls!.first}",
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image, size: 40),
                    title: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    onTap: () {
                      _hideSuggestions();
                      _searchController.text = product.name;
                      FocusScope.of(context).unfocus();
                      _navigateToSearch(product.name);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _navigateToSearch(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultsPage(query: query)),
    );
  }

  void _searchProducts(String query) {
    if (query.isNotEmpty) {
      FocusScope.of(context).unfocus();
      _hideSuggestions();
      _navigateToSearch(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _hideSuggestions();
    FocusScope.of(context).unfocus();
  }

  Future<void> _loadHomePageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _productService.getLatestProducts(limit: 10),
        _productService.getTrending(limit: 10),
        _productService.getDiscounted(limit: 10),
        _productService.getAllProducts(),
        _categoryService.getRootCategories(),
        _vendorService.getAllVendors(),
      ]);

      if (!mounted) return;

      setState(() {
        _latestProducts = results[0] as List<ProductResponse>;
        _trendingProducts = results[1] as List<ProductResponse>;
        _discountedProducts = results[2] as List<ProductResponse>;
        _featuredProducts = (results[3] as List<ProductResponse>)
            .take(10)
            .toList();
        _categories = results[4] as List<CategoryResponse>;
        _vendors = results[5] as List<dynamic>;
      });

      if (_vendors.isNotEmpty) {
        await _loadVendorProducts();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _getUserFriendlyError(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVendorProducts() async {
    if (_vendors.isEmpty) return;

    setState(() {
      _isLoadingVendorProducts = true;
    });

    try {
      _vendorProducts.clear();
      final vendorsToLoad = _vendors.take(3).toList();

      for (var vendor in vendorsToLoad) {
        final vendorId = vendor['id'];
        if (vendorId != null) {
          try {
            final products = await _productService.getDiscounted(limit: 5);

            if (mounted) {
              setState(() {
                _vendorProducts[vendorId] = products;
              });
            }
          } catch (e) {
            debugPrint('Error loading products for vendor $vendorId: $e');
            if (mounted) {
              setState(() {
                _vendorProducts[vendorId] = [];
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading vendor products: $e');
      if (mounted) {
        _showSnackBar('Failed to load some vendor products', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVendorProducts = false;
        });
      }
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socket') || errorString.contains('network')) {
      return 'No internet connection. Please check your network.';
    } else if (errorString.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else {
      return 'Failed to load products. Pull to refresh.';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // void _addToCart(ProductResponse product) {
  //   _showSnackBar('${product.name} added to cart');
  // }
  Future<void> _addToCart(ProductResponse product) async {
    try {
      final token = await _authService.getToken();
      if (token != null) {
        final payload = JwtDecoder.decode(token);
        print('JWT Payload: $payload');
      }

      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        // Redirect to login if not logged in
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
        return;
      }

      final updatedCart = await _cartService.addItem(
        CartItemRequest(productId: product.id, quantity: 1),
      );

      if (!mounted) return;
      setState(() {
        cart = updatedCart;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${product.name} added to cart')));
    } on UnauthorizedException {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add ${product.name}')));
    }
  }

  void _buyNow(ProductResponse product) {
    _showSnackBar('Processing order for ${product.name}');
  }

  // Navigate to category → show category products
  void _navigateToCategory(int? categoryId, String categoryName) {
    print(
      "Navigating to category-------------------- → $categoryName, id: $categoryId",
    );

    if (categoryId == null) {
      print("Category ID is NULL------------------------- → $categoryName");
      return; // prevent navigation
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsPage(
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      ),
    );
  }

  void _navigateToVendor(int vendorId, String vendorName, String? logoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicVendorProductList(
          vendorId: vendorId,
          vendorName: vendorName,
          vendorImage: logoUrl,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    _animationController.dispose();
    _hideSuggestions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: PublicAppMenuDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadHomePageData,
        color: Theme.of(context).primaryColor,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar with Search
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              elevation: 2,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              title: CompositedTransformTarget(
                link: _layerLink,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: _searchProducts,
                    onTap: () {
                      if (_searchSuggestions.isNotEmpty) {
                        _showSuggestions();
                      }
                    },
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart_outlined),
                      onPressed: () {
                        // Cart page এ navigate
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CartPage()),
                        );
                      },
                    ),
                    if (cart != null &&
                        cart!.items.isNotEmpty) // cart null নয় এবং items আছে
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart!.items.length}', // items length দেখাবে
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

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Section
                        _buildHeroSection(),
                        const SizedBox(height: 24),

                        // Categories Section
                        _buildSectionHeader(
                          title: 'Shop by Category',
                          onViewAll: () {},
                        ),
                        const SizedBox(height: 12),
                        _buildCategoriesFromApi(),

                        const SizedBox(height: 24),

                        // Flash Sale Section
                        if (_discountedProducts.isNotEmpty) ...[
                          _buildSectionHeader(
                            title: '🔥 Flash Sale',
                            subtitle: 'Limited time offers',
                            onViewAll: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildProductHorizontalList(_discountedProducts),
                        ],

                        const SizedBox(height: 24),

                        // Trending Products Section
                        if (_trendingProducts.isNotEmpty) ...[
                          _buildSectionHeader(
                            title: '📈 Trending Now',
                            subtitle: 'Most popular products',
                            onViewAll: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildProductHorizontalList(_trendingProducts),
                        ],

                        const SizedBox(height: 24),

                        // Latest Products Section
                        if (_latestProducts.isNotEmpty) ...[
                          _buildSectionHeader(
                            title: '🆕 Latest Arrivals',
                            subtitle: 'New products added',
                            onViewAll: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildProductGrid(_latestProducts.take(4).toList()),
                        ],

                        const SizedBox(height: 24),

                        // Featured Products Section
                        if (_featuredProducts.isNotEmpty) ...[
                          _buildSectionHeader(
                            title: '⭐ Featured Products',
                            subtitle: 'Recommended for you',
                            onViewAll: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildProductGrid(_featuredProducts.take(4).toList()),
                        ],

                        const SizedBox(height: 24),

                        // Top Vendors Section
                        if (_vendors.isNotEmpty) ...[
                          _buildSectionHeader(
                            title: '🏪 Top Vendors',
                            subtitle: 'Best sellers',
                            onViewAll: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildVendorsHorizontalList(),
                        ],

                        const SizedBox(height: 24),

                        // Vendor Products Sections
                        if (_isLoadingVendorProducts)
                          _buildVendorProductsLoading()
                        else
                          ..._buildVendorProductSections(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            // Loading State
            if (_isLoading) SliverToBoxAdapter(child: _buildLoadingShimmer()),

            // Error State
            if (_errorMessage != null && !_isLoading)
              SliverToBoxAdapter(child: _buildErrorView()),
          ],
        ),
      ),
    );
  }

  // Hero Section with PageView and Auto-scroll
  Widget _buildHeroSection() {
    return Column(
      children: [
        // Banner Carousel
        Stack(
          children: [
            GestureDetector(
              onTapDown: (_) => _handleUserInteractionStart(),
              onTapUp: (_) => _handleUserInteractionEnd(),
              onPanDown: (_) => _handleUserInteractionStart(),
              onPanEnd: (_) => _handleUserInteractionEnd(),
              child: SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _bannerImages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: AssetImage(_bannerImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Banner Indicators
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _bannerImages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quick Action Buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickActionButton(
                icon: Icons.local_offer,
                label: 'Today\'s Deal',
                color: Colors.red,
              ),
              _buildQuickActionButton(
                icon: Icons.card_giftcard,
                label: 'Gifts',
                color: Colors.purple,
              ),
              _buildQuickActionButton(
                icon: Icons.local_shipping,
                label: 'Free Shipping',
                color: Colors.blue,
              ),
              _buildQuickActionButton(
                icon: Icons.percent,
                label: 'Coupons',
                color: Colors.green,
              ),
              _buildQuickActionButton(
                icon: Icons.star,
                label: 'Top Rated',
                color: Colors.amber,
              ),
              _buildQuickActionButton(
                icon: Icons.new_releases,
                label: 'New Arrivals',
                color: Colors.teal,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Categories from API
  Widget _buildCategoriesFromApi() {
    // if (_categories.isEmpty) {
    // return _buildEmptyCategories();
    // }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _categories.length > 8 ? 8 : _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return InkWell(
          onTap: () => _navigateToCategory(category.id, category.name),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(index).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: category.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          imageUrl:
                              "${ApiConfig.imgBaseUrl}/${category.imageUrl}",
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Icon(
                            _getCategoryIcon(index),
                            color: _getCategoryColor(index),
                            size: 28,
                          ),
                        ),
                      )
                    : Icon(
                        _getCategoryIcon(index),
                        color: _getCategoryColor(index),
                        size: 28,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCategories() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        final defaultCategories = [
          {
            'name': 'Electronics',
            'icon': Icons.phone_android,
            'color': Colors.blue,
          },
          {'name': 'Fashion', 'icon': Icons.checkroom, 'color': Colors.purple},
          {'name': 'Home', 'icon': Icons.home, 'color': Colors.orange},
          {'name': 'Beauty', 'icon': Icons.spa, 'color': Colors.pink},
          {
            'name': 'Sports',
            'icon': Icons.sports_soccer,
            'color': Colors.green,
          },
          {'name': 'Books', 'icon': Icons.menu_book, 'color': Colors.brown},
          {'name': 'Toys', 'icon': Icons.toys, 'color': Colors.red},
          {
            'name': 'Groceries',
            'icon': Icons.shopping_basket,
            'color': Colors.teal,
          },
        ];

        return InkWell(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (defaultCategories[index]['color'] as Color)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  defaultCategories[index]['icon'] as IconData,
                  color: defaultCategories[index]['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                defaultCategories[index]['name'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // Vendors Horizontal List
  Widget _buildVendorsHorizontalList() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _vendors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final vendor = _vendors[index];
          return InkWell(
            onTap: () => _navigateToVendor(
              vendor['id'],
              vendor['shopName'] ?? 'Vendor',
              vendor['logo'],
            ),
            child: Container(
              width: 80,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: vendor['logo'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "${ApiConfig.imgBaseUrl}/${vendor['logo']}",
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[200]),
                              errorWidget: (context, url, error) => Icon(
                                Icons.store,
                                color: _getVendorColor(index),
                                size: 28,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.store,
                            color: _getVendorColor(index),
                            size: 28,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor['shopName'] ?? 'Shop ${index + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Vendor Products Loading Indicator
  Widget _buildVendorProductsLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Loading vendor products...'),
          ],
        ),
      ),
    );
  }

  // Vendor Product Sections
  List<Widget> _buildVendorProductSections() {
    List<Widget> sections = [];

    _vendorProducts.forEach((vendorId, products) {
      if (products.isNotEmpty) {
        final vendor = _vendors.firstWhere(
          (v) => v['id'] == vendorId,
          orElse: () => {'shopName': 'Vendor $vendorId'},
        );

        sections.addAll([
          const SizedBox(height: 24),
          _buildSectionHeader(
            title: vendor['shopName'] ?? 'Vendor Shop',
            subtitle: '${products.length} products available',
            onViewAll: () => _navigateToVendor(
              vendorId,
              vendor['shopName'] ?? 'Vendor',
              vendor['logo'],
            ),
          ),
          const SizedBox(height: 12),
          _buildProductHorizontalList(products),
        ]);
      }
    });

    return sections;
  }

  // Helper Methods
  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.green,
      Colors.brown,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(int index) {
    final icons = [
      Icons.phone_android,
      Icons.checkroom,
      Icons.home,
      Icons.spa,
      Icons.sports_soccer,
      Icons.menu_book,
      Icons.toys,
      Icons.shopping_basket,
    ];
    return icons[index % icons.length];
  }

  Color _getVendorColor(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _showSnackBar('Opening $label'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? subtitle,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
          ],
        ),
        TextButton(onPressed: onViewAll, child: const Text('View All')),
      ],
    );
  }

  Widget _buildProductHorizontalList(List<ProductResponse> products) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 160,
            child: _buildProductCard(products[index], isHorizontal: true),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<ProductResponse> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(
    ProductResponse product, {
    bool isHorizontal = false,
  }) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;
    final discountPercentage = hasDiscount
        ? ((product.price - product.discountPrice!) / product.price * 100)
              .round()
        : 0;
    final displayPrice = product.discountPrice ?? product.price;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PublicProductDetailsPage(productId: product.id),
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
              offset: const Offset(0, 2),
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

                // Discount Badge
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
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Vendor Badge
                if (product.vendorName != null &&
                    product.vendorName!.isNotEmpty &&
                    product.vendorName!.trim().isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.vendorName![0].toUpperCase(),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.averageRating != null)
                      Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.amber[600]),
                          const SizedBox(width: 2),
                          Text(
                            product.averageRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
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
                    Row(
                      children: [
                        Text(
                          '\$${displayPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
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
                    if (isHorizontal &&
                        product.vendorName != null &&
                        product.vendorName!.isNotEmpty)
                      Text(
                        product.vendorName!,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (isHorizontal)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _addToCart(product),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 28),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Cart',
                                style: TextStyle(fontSize: 10),
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
                                minimumSize: const Size(0, 28),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Buy',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Action Buttons (for grid view)
            if (!isHorizontal)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        // onPressed: () => _addToCart(product),
                        onPressed: () => _addToCart(product),
                        icon: const Icon(Icons.add_shopping_cart, size: 12),
                        label: const Text(
                          'Cart',
                          style: TextStyle(fontSize: 10),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          minimumSize: const Size(0, 28),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
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
                          minimumSize: const Size(0, 28),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Buy',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
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
      child: Column(
        children: [
          Container(
            height: 180,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildShimmerSection(),
                const SizedBox(height: 20),
                _buildShimmerSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 150, height: 20, color: Colors.white),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
        ),
      ],
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
              onPressed: _loadHomePageData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
