import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/vendor/vendor_request.dart';
import 'package:multivendor_flutter_app/services/vendor_service.dart';

class VendorForm extends StatefulWidget {
  final VendorRequest? initialData; // Update এর জন্য
  final int? vendorId;
  final Function()? onSuccess; // Success callback

  const VendorForm({Key? key, this.initialData, this.onSuccess, this.vendorId})
    : super(key: key);

  @override
  State<VendorForm> createState() => _VendorFormState();
}

class _VendorFormState extends State<VendorForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _shopNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _logoController;
  late TextEditingController _bannerController;

  bool _isLoading = false;

  final VendorService _vendorService = VendorService();

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

  void _submitForm() async {
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
        // Create new vendor
        await _vendorService.createVendor(vendorRequest.toJson());
      } else {
        // Update vendor: _vendorService.updateVendor(id, ...)
        await _vendorService.updateVendor(
          widget.vendorId!,
          vendorRequest.toJson(),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vendor saved successfully")),
      );

      if (widget.onSuccess != null) widget.onSuccess!();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _shopNameController,
              decoration: const InputDecoration(labelText: "Shop Name"),
              validator: (value) => value == null || value.isEmpty
                  ? "Shop name is required"
                  : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Business Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            TextFormField(
              controller: _logoController,
              decoration: const InputDecoration(labelText: "Logo URL"),
            ),
            TextFormField(
              controller: _bannerController,
              decoration: const InputDecoration(labelText: "Banner URL"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                      widget.initialData == null
                          ? "Create Vendor"
                          : "Update Vendor",
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
