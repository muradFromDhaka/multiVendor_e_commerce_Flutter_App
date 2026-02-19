class CategoryRequest {
  final String name;
  final String? imageUrl;
  final int? parentId;

  CategoryRequest({required this.name, this.imageUrl, this.parentId});

  Map<String, dynamic> toJson() {
    return {"name": name, "imageUrl": imageUrl, "parentId": parentId};
  }

  factory CategoryRequest.fromJson(Map<String, dynamic> json) {
    return CategoryRequest(
      name: json["name"],
      imageUrl: json["imageUrl"],
      parentId: json["parentId"],
    );
  }
}
