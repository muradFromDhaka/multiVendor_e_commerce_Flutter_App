import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multivendor_flutter_app/models/category/category_request.dart';
import 'package:multivendor_flutter_app/models/category/category_response.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/services/category_service.dart';

class CategoryForm extends StatefulWidget {
  final CategoryResponse? category; // null → CREATE, not null → UPDATE

  const CategoryForm({super.key, this.category});

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final CategoryService _categoryService = CategoryService();

  late TextEditingController _nameController;
  bool _isSaving = false;
  File? _imageFile;

  int? _selectedParentId;
  List<CategoryResponse> _rootCategories = [];
  bool _isLoadingParents = true;

  bool get isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedParentId = widget.category?.parentId?.toInt();
    _loadParentCategories();
  }

  Future<void> _loadParentCategories() async {
    try {
      final parents = await _categoryService.getRootCategories();
      setState(() {
        _rootCategories = parents;
        _isLoadingParents = false;
      });
    } catch (e) {
      setState(() => _isLoadingParents = false);
      // Optional: show error toast/snackbar
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = CategoryRequest(
        name: _nameController.text.trim(),
        imageUrl: null, // image handled separately
        parentId: _selectedParentId,
      );

      if (isEdit) {
        await _categoryService.updateCategory(
          id: widget.category!.id!.toInt(),
          categoryData: request.toJson(),
          imageFile: _imageFile,
        );
      } else {
        await _categoryService.createCategory(
          categoryData: request.toJson(),
          imageFile: _imageFile,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Category updated successfully"
                : "Category created successfully",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }

    if (mounted) setState(() => _isSaving = false);
  }

  Widget _buildImagePicker() {
    Widget imageWidget;

    if (_imageFile != null) {
      imageWidget = CircleAvatar(
        radius: 40,
        backgroundImage: FileImage(_imageFile!),
      );
    } else if (isEdit && widget.category?.imageUrl != null) {
      imageWidget = CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(
          "${ApiConfig.imgBaseUrl}/${widget.category!.imageUrl!}",
        ),
      );
    } else {
      imageWidget = const CircleAvatar(
        radius: 40,
        child: Icon(Icons.camera_alt),
      );
    }

    return Column(
      children: [
        GestureDetector(onTap: _pickImage, child: imageWidget),
        const SizedBox(height: 8),
        const Text("Tap to select image"),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: "Category Name *",
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty)
          return "Category name is required";
        if (value.length > 150) return "Max 150 characters allowed";
        return null;
      },
    );
  }

  Widget _buildParentDropdown() {
    if (_isLoadingParents) return const CircularProgressIndicator();

    return DropdownButtonFormField<int>(
      value: _selectedParentId,
      decoration: const InputDecoration(
        labelText: "Parent Category",
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text("No parent")),
        ..._rootCategories.map(
          (cat) =>
              DropdownMenuItem(value: cat.id!.toInt(), child: Text(cat.name)),
        ),
      ],
      onChanged: (value) => setState(() => _selectedParentId = value),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: _submit,
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(isEdit ? "Update Category" : "Create Category"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Update Category" : "Create Category"),
      ),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImagePicker(),
                const SizedBox(height: 20),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildParentDropdown(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
