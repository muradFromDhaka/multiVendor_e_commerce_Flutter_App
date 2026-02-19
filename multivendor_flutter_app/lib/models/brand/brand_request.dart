class BrandRequest {
  final String name;
  final String? description;
  final String? logoUrl;

  BrandRequest({
    required this.name,
    this.description,
    this.logoUrl,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
    };

    // Remove null values (important for PATCH/PUT)
    data.removeWhere((key, value) => value == null);

    return data;
  }
}