import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multivendor_flutter_app/models/vendor/vendor_response.dart';
import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/services/vendor_service.dart';
import 'package:multivendor_flutter_app/services/order_service.dart';
import 'package:multivendor_flutter_app/ui/vendor/vendor_orders_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/vendor_product/product_List.dart';

class VendorProfile extends StatefulWidget {
  final int? vendorId;

  const VendorProfile({Key? key, this.vendorId}) : super(key: key);

  @override
  State<VendorProfile> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfile> {
  final VendorService _vendorService = VendorService();
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();

  bool _isLoading = true;
  bool _isMyProfile = false;
  VendorResponse? _vendor;
  String? _errorMessage;

  int _totalOrders = 0;
  int _totalProducts = 0;

  @override
  void initState() {
    super.initState();
    _loadVendorProfile();
  }

  Future<void> _loadVendorProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> vendorData;

      if (widget.vendorId != null) {
        vendorData = await _vendorService.getVendorById(widget.vendorId!);
        _isMyProfile = false;
      } else {
        vendorData = await _vendorService.getMyVendor();
        _isMyProfile = true;
      }

      _vendor = VendorResponse.fromJson(vendorData);

      // Fetch stats for my profile
      if (_isMyProfile) {
        final orders = await _orderService.getVendorOrders();
        final products = await _productService.getMyProducts();

        _totalOrders = orders.length;
        _totalProducts = products.length;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_vendor == null) {
      return _buildEmptyView();
    }

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(child: _buildProfileContent()),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: _vendor?.bannerUrl != null ? 250 : 140,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(background: _buildBanner()),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadVendorProfile,
        ),
      ],
    );
  }

  Widget _buildBanner() {
    if (_vendor?.bannerUrl != null) {
      return Image.network(
        _vendor!.bannerUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
      );
    }

    return Container(
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.store, size: 60)),
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildContactCard(),
          if (_isMyProfile) ...[const SizedBox(height: 16), _buildStatsCard()],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundImage: _vendor?.logoUrl != null
              ? NetworkImage(_vendor!.logoUrl!)
              : null,
          child: _vendor?.logoUrl == null
              ? const Icon(Icons.store, size: 32)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _vendor!.shopName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_vendor?.userName != null)
                Text(
                  "Owner: ${_vendor!.userName}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              const SizedBox(height: 6),
              _buildStatusBadge(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;

    switch (_vendor!.status) {
      case VendorStatus.ACTIVE:
        color = Colors.green;
        break;
      case VendorStatus.SUSPENDED:
        color = Colors.red;
        break;
      case VendorStatus.PENDING:
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _vendor!.status.name,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoCard() {
    return _buildCard(
      title: "Vendor Information",
      children: [
        _infoRow(Icons.description, _vendor?.description ?? "No description"),
      ],
    );
  }

  Widget _buildContactCard() {
    return _buildCard(
      title: "Contact Information",
      children: [
        _infoRow(
          Icons.email,
          _vendor?.businessEmail ?? "Not provided",
          copy: true,
        ),
        _infoRow(Icons.phone, _vendor?.phone ?? "Not provided", copy: true),
        _infoRow(Icons.location_on, _vendor?.address ?? "Not provided"),
      ],
    );
  }

  Widget _buildStatsCard() {
    return _buildCard(
      title: "Statistics",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(
              Icons.star,
              _vendor?.rating?.toStringAsFixed(1) ?? "0.0",
              "Rating",
            ),
            _statItem(Icons.shopping_bag, _totalOrders.toString(), "Orders"),
            _statItem(Icons.inventory, _totalProducts.toString(), "Products"),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value, {bool copy = false}) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(value)),
        if (copy && value != "Not provided")
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Copied")));
            },
          ),
      ],
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return GestureDetector(
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
      onTap: () {
        if (label == "Orders") {
          // Navigate to Vendor Orders Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VendorOrdersPage()),
          );
        } else if (label == "Products") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VendorProductList()),
          );
        }
      },
    );
  }

  Widget _buildErrorView() {
    return Center(child: Text(_errorMessage ?? "Error"));
  }

  Widget _buildEmptyView() {
    return const Center(child: Text("No Vendor Profile"));
  }
}
