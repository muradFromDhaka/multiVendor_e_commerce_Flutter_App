class ProductResponse {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? discountPrice;
  final int stockQuantity;
  final String? status;
  final String sku;

  final double? averageRating;
  final int? totalReviews;
  final List<String>? imageUrls;

  final int? categoryId;
  final String? categoryName;

  final int? brandId;
  final String? brandName;

  final int? vendorId;
  final String? vendorName;

  final bool? deleted;
  final String? createdAt;
  final String? updatedAt;

  final int? soldCount;
  final String? releaseDate;

  ProductResponse({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    required this.stockQuantity,
    this.status,
    required this.sku,
    this.averageRating,
    this.totalReviews,
    this.imageUrls,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.vendorId,
    this.vendorName,
    this.deleted,
    this.createdAt,
    this.updatedAt,
    this.soldCount,
    this.releaseDate,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      price: (json["price"] as num).toDouble(),
      discountPrice: json["discountPrice"] != null
          ? (json["discountPrice"] as num).toDouble()
          : null,
      stockQuantity: json["stockQuantity"],
      status: json["status"],
      sku: json["sku"],
      averageRating: json["averageRating"] != null
          ? (json["averageRating"] as num).toDouble()
          : null,
      totalReviews: json["totalReviews"],
      imageUrls: json["imageUrls"] != null
          ? List<String>.from(json["imageUrls"])
          : null,
      categoryId: json["categoryId"],
      categoryName: json["categoryName"],
      brandId: json["brandId"],
      brandName: json["brandName"],
      vendorId: json["vendorId"],
      vendorName: json["vendorName"],
      deleted: json["deleted"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      soldCount: json["soldCount"],
      releaseDate: json["releaseDate"],
    );
  }
}