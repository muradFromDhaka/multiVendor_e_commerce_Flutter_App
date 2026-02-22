class ProductRequest {
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final String sku;
  final int categoryId;
  final int brandId;

  final int? vendorId;
  final double? discountPrice;
  final String? status;
  final String? releaseDate;
  final List<String>? imageUrls;

  ProductRequest({
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    required this.sku,
    required this.categoryId,
    required this.brandId,
    this.vendorId,
    this.discountPrice,
    this.status,
    this.releaseDate,
    this.imageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "price": price,
      "stockQuantity": stockQuantity,
      "sku": sku,
      "categoryId": categoryId,
      "brandId": brandId,
      "vendorId": vendorId,
      "discountPrice": discountPrice,
      "status": status,
      "releaseDate": releaseDate,
      "imageUrls": imageUrls,
    };
  }

  factory ProductRequest.fromJson(Map<String, dynamic> json) {
    return ProductRequest(
      name: json["name"],
      description: json["description"],
      price: (json["price"] as num).toDouble(),
      stockQuantity: json["stockQuantity"],
      sku: json["sku"],
      categoryId: json["categoryId"],
      brandId: json["brandId"],
      vendorId: json["vendorId"],
      discountPrice: json["discountPrice"] != null
          ? (json["discountPrice"] as num).toDouble()
          : null,
      status: json["status"],
      releaseDate: json["releaseDate"],
      imageUrls: json["imageUrls"] != null
          ? List<String>.from(json["imageUrls"])
          : null,
    );
  }
}