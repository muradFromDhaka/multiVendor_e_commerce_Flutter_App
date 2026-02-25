import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multivendor_flutter_app/models/brand/brand_request.dart';
import 'package:multivendor_flutter_app/models/brand/brand_response.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:multivendor_flutter_app/services/brandService.dart';

class BrandForm extends StatefulWidget {
  final BrandResponse? brand; // null হলে CREATE, না হলে UPDATE

  const BrandForm({super.key, this.brand});

  @override
  State<BrandForm> createState() => _BrandFormState();
}

class _BrandFormState extends State<BrandForm> {
  final _formKey = GlobalKey<FormState>();
  final BrandService _brandService = BrandService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  bool _isSaving = false;
  File? _logoFile;

  bool get isEdit => widget.brand != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.brand?.name ?? '');

    _descriptionController = TextEditingController(
      text: widget.brand?.description ?? '',
    );
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      _logoFile = File(picked.path);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = BrandRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (isEdit) {
        await _brandService.updateBrand(
          id: widget.brand!.id,
          brandData: request.toJson(),
          logoFile: _logoFile,
        );
      } else {
        await _brandService.createBrand(
          brandData: request.toJson(),
          logoFile: _logoFile,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Brand updated successfully"
                : "Brand created successfully",
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Update Brand" : "Create Brand")),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildLogoPicker(),
                const SizedBox(height: 20),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPicker() {
    ImageProvider? imageProvider;

    if (_logoFile != null) {
      imageProvider = FileImage(_logoFile!);
    } else if (widget.brand?.logoUrl != null &&
        widget.brand!.logoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(
        "${ApiConfig.imgBaseUrl}/${widget.brand!.logoUrl!}",
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _pickLogo,
          child: CircleAvatar(
            radius: 40,
            backgroundImage: imageProvider,
            child: imageProvider == null ? const Icon(Icons.camera_alt) : null,
          ),
        ),
        const SizedBox(height: 8),
        const Text("Tap to select logo"),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: "Brand Name *",
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Brand name is required";
        }
        if (value.length > 150) {
          return "Max 150 characters allowed";
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: "Description",
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      validator: (value) {
        if (value != null && value.length > 500) {
          return "Max 500 characters allowed";
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: _submit,
        child: _isSaving
            ? const CircularProgressIndicator()
            : Text(isEdit ? "Update Brand" : "Create Brand"),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
