import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:multivendor_flutter_app/models/product/product_response.dart';
import 'package:multivendor_flutter_app/models/product/proudct_request.dart';

import 'api_config.dart';
import 'auth_service.dart';

class ProductService {
  final AuthService _authService = AuthService();

  Uri _url(String path) => Uri.parse("${ApiConfig.baseUrl}$path");

  // ---------------- CREATE PRODUCT ----------------
  Future<ProductResponse> createProduct({
    required ProductRequest product,
    List<File>? images,
  }) async {
    final request = http.MultipartRequest("POST", _url("/products"));

    request.headers.addAll(await _authService.headers(auth: true));

    request.files.add(
      http.MultipartFile.fromString(
        "product",
        jsonEncode(product.toJson()),
        contentType: MediaType("application", "json"),
      ),
    );

    if (images != null && images.isNotEmpty) {
      for (final file in images) {
        request.files.add(
          await http.MultipartFile.fromPath("images", file.path),
        );
      }
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return ProductResponse.fromJson(jsonDecode(body));
    } else {
      throw Exception("Create failed: $body");
    }
  }

  // ---------------- UPDATE PRODUCT ----------------
  Future<ProductResponse> updateProduct({
    required int id,
    required ProductRequest product,
    List<File>? images,
    List<String>? deletedImages,
  }) async {
    final request = http.MultipartRequest("PUT", _url("/products/$id"));

    request.headers.addAll(await _authService.headers(auth: true));

    // ✅ JSON MUST be MultipartFile
    request.files.add(
      http.MultipartFile.fromString(
        "product",
        jsonEncode(product.toJson()),
        contentType: MediaType("application", "json"),
      ),
    );

    if (images != null && images.isNotEmpty) {
      for (final file in images) {
        request.files.add(
          await http.MultipartFile.fromPath("images", file.path),
        );
      }
    }

    // optional যদি backend support করে
    if (deletedImages != null && deletedImages.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromString(
          "deletedImages",
          jsonEncode(deletedImages),
          contentType: MediaType("application", "json"),
        ),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return ProductResponse.fromJson(jsonDecode(body));
    } else {
      throw Exception("Update failed: $body");
    }
  }

  // ---------------- DELETE PRODUCT ----------------
  Future<void> deleteProduct(int id) async {
    final res = await http.delete(
      _url("/products/$id"),
      headers: await _authService.headers(auth: true),
    );

    if (res.statusCode != 200) {
      throw Exception("Delete failed: ${res.body}");
    }
  }

  // ---------------- GET PRODUCT BY ID ----------------
  Future<ProductResponse> getProductById(int id) async {
    final res = await http.get(
      _url("/products/$id"),
      headers: await _authService.headers(),
    );

    if (res.statusCode == 200) {
      return ProductResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Fetch failed: ${res.body}");
    }
  }

  // ---------------- LIST ALL PRODUCTS ----------------
  Future<List<ProductResponse>> getAllProducts() async {
    final res = await http.get(
      _url("/products"),
      headers: await _authService.headers(),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ProductResponse.fromJson(e)).toList();
    } else {
      throw Exception("List failed: ${res.body}");
    }
  }

  // ---------------- FILTERED ENDPOINTS ----------------

  Future<List<ProductResponse>> getLatestProducts({int limit = 10}) async {
    final res = await http.get(
      _url("/products/latest?limit=$limit"),
      headers: await _authService.headers(),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ProductResponse.fromJson(e)).toList();
    } else {
      throw Exception(res.body);
    }
  }

  Future<List<ProductResponse>> getTrending({int limit = 10}) async {
    final res = await http.get(
      _url("/products/trending?limit=$limit"),
      headers: await _authService.headers(),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ProductResponse.fromJson(e)).toList();
    } else {
      throw Exception(res.body);
    }
  }

  Future<List<ProductResponse>> getDiscounted({int limit = 10}) async {
    final res = await http.get(
      _url("/products/discounted?limit=$limit"),
      headers: await _authService.headers(),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ProductResponse.fromJson(e)).toList();
    } else {
      throw Exception(res.body);
    }
  }

  Future<List<ProductResponse>> searchProducts(String keyword) async {
    final res = await http.get(
      _url("/products/search?keyword=$keyword"),
      headers: await _authService.headers(),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ProductResponse.fromJson(e)).toList();
    } else {
      throw Exception(res.body);
    }
  }

  Future<List<ProductResponse>> getProductsByCategory(int categoryId) async {
    final res = await http.get(
      _url("/products/category/$categoryId"),
      headers: await _authService.headers(),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ProductResponse.fromJson(e)).toList();
    } else {
      throw Exception(res.body);
    }
  }

  Future<List<ProductResponse>> getProductsByBrand(int brandId) async {
    final res = await http.get(
      _url("/products/brand/$brandId"),
      headers: await _authService.headers(),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ProductResponse.fromJson(e)).toList();
    } else {
      throw Exception(res.body);
    }
  }

  Future<List<ProductResponse>> getMyProducts() async {
    final res = await http.get(
      _url("/products/my/product"),
      headers: await _authService.headers(auth: true),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ProductResponse.fromJson(e)).toList();
    } else {
      throw Exception(res.body);
    }
  }
}
