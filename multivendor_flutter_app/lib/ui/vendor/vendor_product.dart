import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/ui/admin/product/product_form.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';

class VendorProductList extends StatefulWidget {
  const VendorProductList({super.key});

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

  Future<void> _loadVendorProducts() async {
    setState(() => _isLoading = true);

    try {
      final products = await _productService.getMyProducts(); // vendor products only
      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
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
        builder: (_) => ProductForm(product: product),
        fullscreenDialog: true,
      ),
    );

    if (result == true && mounted) {
      _loadVendorProducts();
    }
  }

  Widget _buildProductCard(ProductResponse product) {
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! < product.price;
    final displayPrice = product.discountPrice ?? product.price;

    return Card(
      child: InkWell(
        onTap: () => _openForm(product: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: (product.imageUrls?.isNotEmpty ?? false)
                  ? CachedNetworkImage(
                      imageUrl: "${ApiConfig.imgBaseUrl}/${product.imageUrls!.first}",
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('\$${displayPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: hasDiscount ? Colors.red : Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Products (${_products.length})'), // show product count
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _products.isEmpty
                  ? const Center(child: Text('You have no products yet'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return _buildProductCard(product);
                      },
                    ),
    );
  }
}