class CategoryResponse {
  final int id;
  final String name;
  final String? imageUrl;

  final int? parentId;
  final String? parentName;

  final List<CategoryResponse>? subCategories;

  CategoryResponse({
    required this.id,
    required this.name,
    this.imageUrl,
    this.parentId,
    this.parentName,
    this.subCategories,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      id: json["id"],
      name: json["name"],
      imageUrl: json["imageUrl"],
      parentId: json["parentId"],
      parentName: json["parentName"],
      subCategories: json["subCategories"] != null
          ? (json["subCategories"] as List)
              .map((e) => CategoryResponse.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "imageUrl": imageUrl,
      "parentId": parentId,
      "parentName": parentName,
      "subCategories":
          subCategories?.map((e) => e.toJson()).toList(),
    };
  }
}