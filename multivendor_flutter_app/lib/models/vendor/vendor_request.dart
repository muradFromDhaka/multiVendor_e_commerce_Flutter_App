class VendorRequest {
  final String shopName;
  final String? description;
  final String? businessEmail;
  final String? phone;
  final String? address;
  final String? logoUrl;
  final String? bannerUrl;

  VendorRequest({
    required this.shopName,
    this.description,
    this.businessEmail,
    this.phone,
    this.address,
    this.logoUrl,
    this.bannerUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "shopName": shopName,
      "description": description,
      "businessEmail": businessEmail,
      "phone": phone,
      "address": address,
      "logoUrl": logoUrl,
      "bannerUrl": bannerUrl,
    };
  }
}