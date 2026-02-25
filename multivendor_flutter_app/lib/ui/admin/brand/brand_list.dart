import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/brand/brand_response.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/services/brandService.dart';

import 'brand_form.dart';

class BrandList extends StatefulWidget {
  const BrandList({super.key});

  @override
  State<BrandList> createState() => _BrandListState();
}

class _BrandListState extends State<BrandList> {
  final BrandService _brandService = BrandService();

  bool _isLoading = true;
  String? _error;
  List<BrandResponse> _brands = [];

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await _brandService.getAllBrands();

      final brands = res
          .map<BrandResponse>((json) => BrandResponse.fromJson(json))
          .toList();

      setState(() {
        _brands = brands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBrand(BrandResponse brand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Brand"),
        content: Text("Are you sure you want to delete '${brand.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _brandService.deleteBrand(brand.id);

      setState(() {
        _brands.removeWhere((b) => b.id == brand.id);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Brand deleted")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _openForm({BrandResponse? brand}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrandForm(brand: brand)),
    );

    if (result == true) {
      _loadBrands();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Brands page"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _openForm(),
            icon: Row(children: [Icon(Icons.add), Text("Add Brand")]),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBrands),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadBrands, child: const Text("Retry")),
          ],
        ),
      );
    }

    if (_brands.isEmpty) {
      return const Center(child: Text("No brands found"));
    }

    return RefreshIndicator(
      onRefresh: _loadBrands,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _brands.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (_, index) {
          final brand = _brands[index];
          return _BrandCard(
            brand: brand,
            onEdit: () => _openForm(brand: brand),
            onDelete: () => _deleteBrand(brand),
          );
        },
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandResponse brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BrandCard({
    required this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Column(
        children: [
          const SizedBox(height: 12),

          CircleAvatar(
            radius: 28,
            backgroundImage: brand.logoUrl != null
                ? NetworkImage("${ApiConfig.imgBaseUrl}/${brand.logoUrl!}")
                : null,
            child: brand.logoUrl == null
                ? const Icon(Icons.image_not_supported)
                : null,
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              brand.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              brand.description ?? "No description",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
