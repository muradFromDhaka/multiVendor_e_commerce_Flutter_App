import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:multivendor_flutter_app/models/brand/brand_response.dart';
import 'package:multivendor_flutter_app/models/category/category_response.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/models/product/proudct_request.dart';
import 'package:multivendor_flutter_app/models/vendor/vendor_response.dart';

import 'package:multivendor_flutter_app/services/ProductService.dart';
import 'package:multivendor_flutter_app/services/brandService.dart';
import 'package:multivendor_flutter_app/services/category_service.dart';
import 'package:multivendor_flutter_app/services/vendor_service.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/ui/vendor/dashboard_page.dart';
import 'package:multivendor_flutter_app/ui/vendor/vendor_product/product_List.dart';

class VendorProductForm extends StatefulWidget {
  final ProductResponse? product;

  const VendorProductForm({super.key, this.product});

  @override
  State<VendorProductForm> createState() => _VendorProductFormState();
}

class _VendorProductFormState extends State<VendorProductForm> {
  final _formKey = GlobalKey<FormState>();

  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final BrandService _brandService = BrandService();
  final VendorService _vendorService = VendorService();
  final AuthService _authService = AuthService();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();

  bool _isSaving = false;
  bool _isAdmin = false;
  int? _loggedVendorId;

  List<File> _pickedImages = [];
  List<String> _existingImages = [];

  List<CategoryResponse> _categories = [];
  List<BrandResponse> _brands = [];
  List<VendorResponse> _vendors = [];

  CategoryResponse? _selectedCategory;
  BrandResponse? _selectedBrand;
  VendorResponse? _selectedVendor;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    _initRoles();
    _loadInitialData();
    _loadVendorId();

    if (isEdit) {
      final p = widget.product!;

      _nameController.text = p.name;
      _descController.text = p.description ?? '';
      _priceController.text = p.price.toString();
      _stockController.text = p.stockQuantity.toString();
      _skuController.text = p.sku;

      _existingImages = List.from(p.imageUrls ?? []);
    }
  }

  /* ================= ROLES ================= */

  Future<void> _initRoles() async {
    final isAdmin = await _authService.hasRole('ROLE_ADMIN');

    if (!mounted) return;

    setState(() => _isAdmin = isAdmin);

    if (isAdmin) {
      _loadVendors();
    }
  }

  Future<void> _loadVendorId() async {
    final vendorId = await _authService.getVendorId();

    print("Loaded VendorId ===================== $vendorId");

    if (!mounted) return;

    setState(() => _loggedVendorId = vendorId);
  }

  /* ================= LOADERS ================= */

  Future<void> _loadInitialData() async {
    try {
      final categories = await _categoryService.getAllCategories();
      final brandsRaw = await _brandService.getAllBrands();

      final brands = brandsRaw
          .map<BrandResponse>((b) => BrandResponse.fromJson(b))
          .toList();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _brands = brands;
      });

      if (isEdit) _preselectEditData();
    } catch (e) {
      debugPrint("Init load error: $e");
    }
  }

  Future<void> _loadVendors() async {
    try {
      final raw = await _vendorService.getAllVendors();

      final vendors = raw
          .map<VendorResponse>((v) => VendorResponse.fromJson(v))
          .toList();

      if (!mounted) return;

      setState(() => _vendors = vendors);

      if (isEdit) _preselectEditVendor();
    } catch (e) {
      debugPrint("Vendor load error: $e");
    }
  }

  /* ================= EDIT PRESELECT ================= */

  void _preselectEditData() {
    final p = widget.product!;

    _selectedCategory = _categories
        .where((c) => c.id == p.categoryId)
        .firstOrNull;

    _selectedBrand = _brands.where((b) => b.id == p.brandId).firstOrNull;
  }

  void _preselectEditVendor() {
    final p = widget.product!;

    _selectedVendor = _vendors.where((v) => v.id == p.vendorId).firstOrNull;
  }

  /* ================= IMAGES ================= */

  Future<void> _pickImages() async {
    final picker = ImagePicker();

    final images = await picker.pickMultiImage(
      imageQuality: 70,
      maxHeight: 1024,
      maxWidth: 1024,
    );

    if (images.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  Widget _buildImages() {
    final images = [
      ..._existingImages.map(
        (url) => Stack(
          children: [
            Image.network(
              "${ApiConfig.imgBaseUrl}/$url",
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => setState(() => _existingImages.remove(url)),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      ..._pickedImages.map(
        (file) => Stack(
          children: [
            Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => setState(() => _pickedImages.remove(file)),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: images),
        TextButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.image),
          label: const Text("Pick Images"),
        ),
      ],
    );
  }

  /* ================= SUBMIT ================= */
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null || _selectedBrand == null) {
      _showError("Category & Brand required");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final request = ProductRequest(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stockQuantity: int.parse(_stockController.text.trim()),
        sku: _skuController.text.trim(),
        categoryId: _selectedCategory!.id!,
        brandId: _selectedBrand!.id!,
        vendorId: _resolveVendorId(),
        imageUrls: _existingImages,
      );

      if (isEdit) {
        await _productService.updateProduct(
          id: widget.product!.id,
          product: request,
          images: _pickedImages,
        );
      } else {
        await _productService.createProduct(
          product: request,
          images: _pickedImages,
        );
      }

      if (!mounted) return;

      // Success, navigate back or to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VendorDashboardPage()),
      );
    } catch (e) {
      String errorMessage = "Something went wrong";

      // MySQL Duplicate Entry Error
      if (e.toString().contains('Duplicate entry')) {
        errorMessage = "Product with this SKU already exists";
      }
      // Optional: catch specific network errors, validation errors, etc.
      else if (e.toString().contains('Failed host lookup')) {
        errorMessage = "No internet connection";
      }

      _showError(errorMessage);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Show Snackbar error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  int _resolveVendorId() {
    if (_isAdmin) {
      if (_selectedVendor == null) {
        throw Exception("Vendor required");
      }
      return _selectedVendor!.id!;
    }

    if (_loggedVendorId == null) {
      throw Exception("Vendor is not found(JWT issue)");
    }

    return _loggedVendorId!;
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Update Product" : "Create Product")),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImages(),
                const SizedBox(height: 16),
                _buildText(_nameController, "Name"),
                const SizedBox(height: 12),
                _buildText(_descController, "Description", maxLines: 3),
                const SizedBox(height: 12),
                _buildNumber(_priceController, "Price"),
                const SizedBox(height: 12),
                _buildNumber(_stockController, "Stock"),
                const SizedBox(height: 12),
                _buildText(_skuController, "SKU"),
                const SizedBox(height: 12),
                _buildCategoryDropdown(),
                const SizedBox(height: 12),
                _buildBrandDropdown(),
                if (_isAdmin) ...[
                  const SizedBox(height: 12),
                  _buildVendorDropdown(),
                ],
                const SizedBox(height: 24),
                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVendorDropdown() => DropdownButtonFormField<VendorResponse>(
    value: _selectedVendor,
    items: _vendors
        .map((v) => DropdownMenuItem(value: v, child: Text(v.shopName ?? "")))
        .toList(),
    onChanged: (v) => setState(() => _selectedVendor = v),
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      labelText: "Vendor",
    ),
    validator: (v) => v == null ? "Required" : null,
  );

  Widget _buildCategoryDropdown() => DropdownButtonFormField<CategoryResponse>(
    value: _selectedCategory,
    items: _categories
        .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
        .toList(),
    onChanged: (v) => setState(() => _selectedCategory = v),
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      labelText: "Category",
    ),
    validator: (v) => v == null ? "Required" : null,
  );

  Widget _buildBrandDropdown() => DropdownButtonFormField<BrandResponse>(
    value: _selectedBrand,
    items: _brands
        .map((b) => DropdownMenuItem(value: b, child: Text(b.name ?? "")))
        .toList(),
    onChanged: (v) => setState(() => _selectedBrand = v),
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      labelText: "Brand",
    ),
    validator: (v) => v == null ? "Required" : null,
  );

  Widget _buildText(
    TextEditingController c,
    String label, {
    int maxLines = 1,
  }) => TextFormField(
    controller: c,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
  );

  Widget _buildNumber(TextEditingController c, String label) => TextFormField(
    controller: c,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
  );

  Widget _buildButton() => SizedBox(
    width: double.infinity,
    height: 46,
    child: ElevatedButton(
      onPressed: _submit,
      child: _isSaving
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(isEdit ? "Update Product" : "Create Product"),
    ),
  );
}

/* ================= EXTENSION ================= */

extension FirstOrNullExt<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
