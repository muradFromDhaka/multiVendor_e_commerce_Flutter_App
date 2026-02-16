import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/vendor/vendor_request.dart';
import 'package:multivendor_flutter_app/models/vendor/vendor_response.dart';
import 'package:multivendor_flutter_app/services/vendor_service.dart';
import 'vendor_form.dart';

class VendorProfile extends StatefulWidget {
  const VendorProfile({Key? key}) : super(key: key);

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  final VendorService _vendorService = VendorService();

  VendorResponse? _vendor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendor();
  }

  void _loadVendor() async {
    try {
      final data = await _vendorService.getMyVendor();
      setState(() {
        _vendor = VendorResponse.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading vendor: $e")));
    }
  }

  void _openEditForm() {
    if (_vendor == null) return;

    final vendorRequest = VendorRequest(
      shopName: _vendor!.shopName,
      description: _vendor!.description,
      businessEmail: _vendor!.businessEmail,
      phone: _vendor!.phone,
      address: _vendor!.address,
      logoUrl: _vendor!.logoUrl,
      bannerUrl: _vendor!.bannerUrl,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: VendorForm(
          initialData: vendorRequest,
          vendorId: _vendor!.id,
          onSuccess: () {
            Navigator.of(context).pop();
            _loadVendor(); // Refresh profile after edit
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Profile"),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _openEditForm),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vendor == null
          ? const Center(child: Text("Vendor not found"))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_vendor!.bannerUrl != null &&
                      _vendor!.bannerUrl!.isNotEmpty)
                    Image.network(
                      _vendor!.bannerUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _vendor!.logoUrl != null
                              ? NetworkImage(_vendor!.logoUrl!)
                              : null,
                          child: _vendor!.logoUrl == null
                              ? const Icon(Icons.store, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _vendor!.shopName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey[300], thickness: 2),
                  ListTile(
                    title: const Text("Description"),
                    subtitle: Text(_vendor!.description ?? "-"),
                  ),
                  ListTile(
                    title: const Text("Business Email"),
                    subtitle: Text(_vendor!.businessEmail ?? "-"),
                  ),
                  ListTile(
                    title: const Text("Phone"),
                    subtitle: Text(_vendor!.phone ?? "-"),
                  ),
                  ListTile(
                    title: const Text("Address"),
                    subtitle: Text(_vendor!.address ?? "-"),
                  ),
                  ListTile(
                    title: const Text("Rating"),
                    subtitle: Text(_vendor!.rating?.toString() ?? "-"),
                  ),
                  ListTile(
                    title: const Text("Status"),
                    subtitle: Text(_vendor!.status.toString().split('.').last),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
