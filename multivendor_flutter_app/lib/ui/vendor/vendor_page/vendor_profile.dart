// // vendor_profile_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:multivendor_flutter_app/models/vendor/vendor_response.dart';
// import 'package:multivendor_flutter_app/services/vendor_service.dart';

// class VendorProfile extends StatefulWidget {
//   final int? vendorId; // If null, shows current user's vendor profile

//   const VendorProfile({Key? key, this.vendorId}) : super(key: key);

//   @override
//   State<VendorProfile> createState() => _VendorProfilePageState();
// }

// class _VendorProfilePageState extends State<VendorProfile> {
//   final VendorService _vendorService = VendorService();
//   final _formKey = GlobalKey<FormState>();
//   final _scaffoldKey = GlobalKey<ScaffoldState>();

//   // Controllers
//   late TextEditingController _shopNameController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _businessEmailController;
//   late TextEditingController _phoneController;
//   late TextEditingController _addressController;

//   // State
//   bool _isLoading = true;
//   bool _isSaving = false;
//   bool _isEditing = false;
//   bool _isMyProfile = false;
//   VendorResponse? _vendor;
//   String? _errorMessage;

//   // Image picking (would need image_picker package)
//   Uint8List? _selectedLogo;
//   Uint8List? _selectedBanner;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _loadVendorProfile();
//   }

//   void _initializeControllers() {
//     _shopNameController = TextEditingController();
//     _descriptionController = TextEditingController();
//     _businessEmailController = TextEditingController();
//     _phoneController = TextEditingController();
//     _addressController = TextEditingController();
//   }

//   Future<void> _loadVendorProfile() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       Map<String, dynamic> vendorData;

//       if (widget.vendorId != null) {
//         vendorData = await _vendorService.getVendorById(widget.vendorId!);
//         _isMyProfile = false;
//       } else {
//         vendorData = await _vendorService.getMyVendor();
//         _isMyProfile = true;
//       }

//       final vendor = VendorResponse.fromJson(vendorData);

//       setState(() {
//         _vendor = vendor;
//         _populateControllers(vendor);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString().replaceAll('Exception: ', '');
//         _isLoading = false;
//       });

//       _showSnackBar('Error loading profile: ${e.toString()}', isError: true);
//     }
//   }

//   void _populateControllers(VendorResponse vendor) {
//     _shopNameController.text = vendor.shopName;
//     _descriptionController.text = vendor.description ?? '';
//     _businessEmailController.text = vendor.businessEmail ?? '';
//     _phoneController.text = vendor.phone ?? '';
//     _addressController.text = vendor.address ?? '';
//   }

//   Future<void> _saveVendorProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       final Map<String, dynamic> updateData = {
//         'shopName': _shopNameController.text.trim(),
//         'description': _descriptionController.text.trim().isEmpty
//             ? null
//             : _descriptionController.text.trim(),
//         'businessEmail': _businessEmailController.text.trim().isEmpty
//             ? null
//             : _businessEmailController.text.trim(),
//         'phone': _phoneController.text.trim().isEmpty
//             ? null
//             : _phoneController.text.trim(),
//         'address': _addressController.text.trim().isEmpty
//             ? null
//             : _addressController.text.trim(),
//       };

//       // Remove null values
//       updateData.removeWhere((key, value) => value == null);

//       final response = await _vendorService.updateVendor(
//         _vendor!.id,
//         updateData,
//       );

//       final updatedVendor = VendorResponse.fromJson(response);

//       setState(() {
//         _vendor = updatedVendor;
//         _isEditing = false;
//         _isSaving = false;
//       });

//       _showSnackBar('Profile updated successfully!');
//     } catch (e) {
//       setState(() {
//         _isSaving = false;
//       });

//       _showSnackBar('Error updating profile: ${e.toString()}', isError: true);
//     }
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void _toggleEditMode() {
//     setState(() {
//       if (_isEditing) {
//         // Cancel editing - revert changes
//         _populateControllers(_vendor!);
//       }
//       _isEditing = !_isEditing;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(key: _scaffoldKey, body: _buildBody());
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_errorMessage != null) {
//       return _buildErrorView();
//     }

//     if (_vendor == null) {
//       return _buildEmptyView();
//     }

//     return CustomScrollView(
//       slivers: [
//         _buildSliverAppBar(),
//         SliverToBoxAdapter(child: _buildProfileContent()),
//       ],
//     );
//   }

//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       expandedHeight: _vendor?.bannerUrl != null ? 200 : 150,
//       floating: false,
//       pinned: true,
//       stretch: true,
//       backgroundColor: Theme.of(context).primaryColor,
//       flexibleSpace: FlexibleSpaceBar(
//         stretchModes: const [StretchMode.zoomBackground],
//         background: _buildBannerSection(),
//         title: _isEditing
//             ? null
//             : Text(
//                 _vendor?.shopName ?? 'Vendor Profile',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//       ),
//       actions: _buildAppBarActions(),
//     );
//   }

//   List<Widget> _buildAppBarActions() {
//     if (!_isMyProfile) return [];

//     if (_isEditing) {
//       return [
//         IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: _toggleEditMode,
//           tooltip: 'Cancel',
//         ),
//         IconButton(
//           icon: _isSaving
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//               : const Icon(Icons.check),
//           onPressed: _isSaving ? null : _saveVendorProfile,
//           tooltip: 'Save',
//         ),
//       ];
//     }

//     return [
//       IconButton(
//         icon: const Icon(Icons.edit),
//         onPressed: _toggleEditMode,
//         tooltip: 'Edit Profile',
//       ),
//       IconButton(
//         icon: const Icon(Icons.refresh),
//         onPressed: _loadVendorProfile,
//         tooltip: 'Refresh',
//       ),
//     ];
//   }

//   Widget _buildBannerSection() {
//     if (_vendor?.bannerUrl != null) {
//       return Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.network(
//             _vendor!.bannerUrl!,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(color: Colors.grey[300]);
//             },
//           ),
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
//               ),
//             ),
//           ),
//         ],
//       );
//     }

//     return Container(
//       color: Colors.grey[300],
//       child: Center(
//         child: Icon(Icons.store, size: 80, color: Colors.grey[600]),
//       ),
//     );
//   }

//   Widget _buildProfileContent() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildLogoAndStatusSection(),
//             const SizedBox(height: 24),
//             _buildVendorInfoSection(),
//             const SizedBox(height: 24),
//             _buildContactInfoSection(),
//             if (!_isMyProfile && _vendor?.status != null) ...[
//               const SizedBox(height: 24),
//               _buildStatusCard(),
//             ],
//             if (_isMyProfile && _vendor?.status != null) ...[
//               const SizedBox(height: 24),
//               _buildStatsSection(),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLogoAndStatusSection() {
//     return Row(
//       children: [
//         _buildLogo(),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (!_isEditing) ...[
//                 Text(
//                   _vendor!.shopName,
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (_vendor?.userName != null) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     'Owner: ${_vendor!.userName}',
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
//                   ),
//                 ],
//               ],
//               const SizedBox(height: 8),
//               _buildStatusBadge(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLogo() {
//     if (_vendor?.logoUrl != null) {
//       return CircleAvatar(
//         radius: 40,
//         backgroundImage: NetworkImage(_vendor!.logoUrl!),
//         onBackgroundImageError: (_, __) {},
//         child: const Icon(Icons.store, size: 40),
//       );
//     }

//     return CircleAvatar(
//       radius: 40,
//       backgroundColor: Colors.grey[300],
//       child: const Icon(Icons.store, size: 40, color: Colors.white),
//     );
//   }

//   Widget _buildStatusBadge() {
//     Color color;
//     String text;

//     switch (_vendor!.status) {
//       case VendorStatus.ACTIVE:
//         color = Colors.green;
//         text = 'Active';
//         break;
//       case VendorStatus.SUSPENDED:
//         color = Colors.red;
//         text = 'Suspended';
//         break;
//       case VendorStatus.PENDING:
//         color = Colors.orange;
//         text = 'Pending Approval';
//         break;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.5)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             text,
//             style: TextStyle(
//               color: color,
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVendorInfoSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.info_outline, color: Colors.grey[700]),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Vendor Information',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),
//             if (_isEditing) ...[
//               TextFormField(
//                 controller: _shopNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Shop Name *',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.store),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Shop name is required';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.description),
//                   alignLabelWithHint: true,
//                 ),
//                 maxLines: 3,
//               ),
//             ] else ...[
//               _buildInfoRow(
//                 icon: Icons.description,
//                 label: 'Description',
//                 value: _vendor?.description ?? 'No description provided',
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContactInfoSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.contact_mail, color: Colors.grey[700]),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Contact Information',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),
//             if (_isEditing) ...[
//               TextFormField(
//                 controller: _businessEmailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Business Email',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value != null && value.isNotEmpty) {
//                     if (!RegExp(
//                       r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                     ).hasMatch(value)) {
//                       return 'Enter a valid email';
//                     }
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone Number',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.phone),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(
//                   labelText: 'Address',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.location_on),
//                 ),
//                 maxLines: 2,
//               ),
//             ] else ...[
//               _buildInfoRow(
//                 icon: Icons.email,
//                 label: 'Business Email',
//                 value: _vendor?.businessEmail ?? 'Not provided',
//                 canCopy: true,
//               ),
//               const SizedBox(height: 12),
//               _buildInfoRow(
//                 icon: Icons.phone,
//                 label: 'Phone',
//                 value: _vendor?.phone ?? 'Not provided',
//                 canCopy: true,
//               ),
//               const SizedBox(height: 12),
//               _buildInfoRow(
//                 icon: Icons.location_on,
//                 label: 'Address',
//                 value: _vendor?.address ?? 'Not provided',
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow({
//     required IconData icon,
//     required String label,
//     required String value,
//     bool canCopy = false,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 20, color: Colors.grey[600]),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//               ),
//               const SizedBox(height: 2),
//               Text(value, style: const TextStyle(fontSize: 16)),
//             ],
//           ),
//         ),
//         if (canCopy && value != 'Not provided')
//           IconButton(
//             icon: const Icon(Icons.copy, size: 20),
//             onPressed: () {
//               Clipboard.setData(ClipboardData(text: value));
//               _showSnackBar('Copied to clipboard');
//             },
//           ),
//       ],
//     );
//   }

//   Widget _buildStatusCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: _vendor!.status == VendorStatus.ACTIVE
//           ? Colors.green.shade50
//           : _vendor!.status == VendorStatus.SUSPENDED
//           ? Colors.red.shade50
//           : Colors.orange.shade50,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(
//               _vendor!.status == VendorStatus.ACTIVE
//                   ? Icons.check_circle
//                   : _vendor!.status == VendorStatus.SUSPENDED
//                   ? Icons.cancel
//                   : Icons.pending,
//               color: _vendor!.status == VendorStatus.ACTIVE
//                   ? Colors.green
//                   : _vendor!.status == VendorStatus.SUSPENDED
//                   ? Colors.red
//                   : Colors.orange,
//               size: 32,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Account Status',
//                     style: TextStyle(color: Colors.grey[700], fontSize: 14),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _vendor!.status == VendorStatus.ACTIVE
//                         ? 'Active and accepting orders'
//                         : _vendor!.status == VendorStatus.SUSPENDED
//                         ? 'Account suspended - contact support'
//                         : 'Pending approval - verification in progress',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatItem(
//                   icon: Icons.star,
//                   value: _vendor?.rating?.toStringAsFixed(1) ?? '0.0',
//                   label: 'Rating',
//                 ),
//                 Container(height: 40, width: 1, color: Colors.grey[300]),
//                 _buildStatItem(
//                   icon: Icons.shopping_bag,
//                   value: '0', // Would come from API
//                   label: 'Orders',
//                 ),
//                 Container(height: 40, width: 1, color: Colors.grey[300]),
//                 _buildStatItem(
//                   icon: Icons.inventory,
//                   value: '0', // Would come from API
//                   label: 'Products',
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem({
//     required IconData icon,
//     required String value,
//     required String label,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.grey[700]),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//       ],
//     );
//   }

//   Widget _buildErrorView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//             const SizedBox(height: 16),
//             Text(
//               'Error Loading Profile',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _errorMessage!,
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _loadVendorProfile,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Try Again'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.storefront, size: 80, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             'No Vendor Profile',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'You haven\'t created a vendor profile yet',
//             style: TextStyle(color: Colors.grey[600]),
//           ),
//           if (_isMyProfile) ...[
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Navigate to create vendor page
//               },
//               icon: const Icon(Icons.add_business),
//               label: const Text('Create Vendor Profile'),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _shopNameController.dispose();
//     _descriptionController.dispose();
//     _businessEmailController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multivendor_flutter_app/models/vendor/vendor_response.dart';
import 'package:multivendor_flutter_app/services/vendor_service.dart';

class VendorProfile extends StatefulWidget {
  final int? vendorId;

  const VendorProfile({Key? key, this.vendorId}) : super(key: key);

  @override
  State<VendorProfile> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfile> {
  final VendorService _vendorService = VendorService();

  bool _isLoading = true;
  bool _isMyProfile = false;
  VendorResponse? _vendor;
  String? _errorMessage;

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

      setState(() {
        _vendor = VendorResponse.fromJson(vendorData);
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
      flexibleSpace: FlexibleSpaceBar(
        background: _buildBanner(),
      ),
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
            _statItem(Icons.shopping_bag, "0", "Orders"),
            _statItem(Icons.inventory, "0", "Products"),
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
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(child: Text(_errorMessage ?? "Error"));
  }

  Widget _buildEmptyView() {
    return const Center(child: Text("No Vendor Profile"));
  }
}
