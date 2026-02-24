import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/vendor/vendor_request.dart';
import 'package:multivendor_flutter_app/services/vendor_service.dart';
import 'package:multivendor_flutter_app/ui/vendor/vendor_page/vendor_profile.dart';

class VendorForm extends StatefulWidget {
  final VendorRequest? initialData;
  final int? vendorId;
  final VoidCallback? onSuccess;

  const VendorForm({Key? key, this.initialData, this.vendorId, this.onSuccess})
    : super(key: key);

  @override
  State<VendorForm> createState() => _VendorFormState();
}

class _VendorFormState extends State<VendorForm> {
  final _formKey = GlobalKey<FormState>();
  final _vendorService = VendorService();

  late final TextEditingController _shopNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _logoController;
  late final TextEditingController _bannerController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _shopNameController = TextEditingController(
      text: widget.initialData?.shopName ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialData?.description ?? '',
    );
    _emailController = TextEditingController(
      text: widget.initialData?.businessEmail ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialData?.phone ?? '',
    );
    _addressController = TextEditingController(
      text: widget.initialData?.address ?? '',
    );
    _logoController = TextEditingController(
      text: widget.initialData?.logoUrl ?? '',
    );
    _bannerController = TextEditingController(
      text: widget.initialData?.bannerUrl ?? '',
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _logoController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final vendorRequest = VendorRequest(
      shopName: _shopNameController.text.trim(),
      description: _descriptionController.text.trim(),
      businessEmail: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      logoUrl: _logoController.text.trim(),
      bannerUrl: _bannerController.text.trim(),
    );

    setState(() => _isLoading = true);

    try {
      if (widget.initialData == null) {
        await _vendorService.createVendor(vendorRequest.toJson());

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VendorProfile()),
        );
      } else {
        await _vendorService.updateVendor(
          widget.vendorId!,
          vendorRequest.toJson(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vendor saved successfully")),
      );

      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _imagePreview(String url) {
    if (url.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          height: 80,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Text(
            "Invalid image URL",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initialData == null ? "Create Vendor" : "Update Vendor",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _shopNameController,
                decoration: _decoration("Shop Name"),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    _requiredValidator(v, "Shop name is required"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                decoration: _decoration("Description"),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                decoration: _decoration("Business Email"),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: _decoration("Phone"),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                decoration: _decoration("Address"),
                maxLines: 2,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _logoController,
                decoration: _decoration("Logo URL"),
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              _imagePreview(_logoController.text),

              const SizedBox(height: 12),

              TextFormField(
                controller: _bannerController,
                decoration: _decoration("Banner URL"),
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
              ),
              _imagePreview(_bannerController.text),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.initialData == null
                            ? "Create Vendor"
                            : "Update Vendor",
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
