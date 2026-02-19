class BrandResponse {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;

  BrandResponse({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
  });

  factory BrandResponse.fromJson(Map<String, dynamic> json) {
    return BrandResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logoUrl: json['logoUrl'],
    );
  }
}