class VendorResponse {
  final int id;
  final String shopName;
  final String? slug;
  final String? description;
  final VendorStatus status;
  final double? rating;
  final String? userName;

  final String? businessEmail;
  final String? phone;
  final String? address;
  final String? logoUrl;
  final String? bannerUrl;

  VendorResponse({
    required this.id,
    required this.shopName,
    this.slug,
    this.description,
    required this.status,
    this.rating,
    this.userName,
    this.businessEmail,
    this.phone,
    this.address,
    this.logoUrl,
    this.bannerUrl,
  });

  factory VendorResponse.fromJson(Map<String, dynamic> json) {
    return VendorResponse(
      id: json['id'],
      shopName: json['shopName'],
      slug: json['slug'],
      description: json['description'],

      // ✅ FIXED
      status: VendorStatus.fromString(json['status']?.toString()),

      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,

      userName: json['userName'],
      businessEmail: json['businessEmail'],
      phone: json['phone'],
      address: json['address'],
      logoUrl: json['logoUrl'],
      bannerUrl: json['bannerUrl'],
    );
  }
}

//==================VendorStatus=======================
enum VendorStatus {
  PENDING,
  ACTIVE,
  SUSPENDED;

  static VendorStatus fromString(String? value) {
    switch (value) {
      case 'ACTIVE':
        return VendorStatus.ACTIVE;
      case 'SUSPENDED':
        return VendorStatus.SUSPENDED;
      case 'PENDING':
      default:
        return VendorStatus.PENDING;
    }
  }
}