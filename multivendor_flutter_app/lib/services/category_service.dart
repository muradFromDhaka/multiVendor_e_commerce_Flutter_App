import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import '../models/category/category_response.dart';
import '../services/api_config.dart';
import '../services/auth_service.dart';

class CategoryService {
  final AuthService _authService = AuthService();

  /* ================= GET ALL CATEGORIES ================= */

  Future<List<CategoryResponse>> getAllCategories() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/categories"),
      headers: await _authService.headers(),
    );

    _checkError(res);

    final List data = jsonDecode(res.body);
    return data.map((e) => CategoryResponse.fromJson(e)).toList();
  }

  /* ================= GET ROOT CATEGORIES ================= */

  Future<List<CategoryResponse>> getRootCategories() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/categories/root"),
      headers: await _authService.headers(),
    );

    _checkError(res);

    final List data = jsonDecode(res.body);
    return data.map((e) => CategoryResponse.fromJson(e)).toList();
  }

  /* ================= GET CATEGORY BY ID ================= */

  Future<CategoryResponse> getCategoryById(int id) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/categories/$id"),
      headers: await _authService.headers(),
    );

    _checkError(res);

    return CategoryResponse.fromJson(jsonDecode(res.body));
  }

  /* ================= GET SUBCATEGORIES ================= */

  Future<List<CategoryResponse>> getSubCategories(int id) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/categories/$id/subcategories"),
      headers: await _authService.headers(),
    );

    _checkError(res);

    final List data = jsonDecode(res.body);
    return data.map((e) => CategoryResponse.fromJson(e)).toList();
  }

  /* ================= CREATE CATEGORY ================= */

  Future<CategoryResponse> createCategory({
    required Map<String, dynamic> categoryData,
    File? imageFile,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/categories");

    final request = http.MultipartRequest("POST", uri);

    final headers = await _authService.headers(auth: true);
    request.headers.addAll(headers);

    request.files.add(
      http.MultipartFile.fromString(
        "category",
        jsonEncode(categoryData),
        contentType: http_parser.MediaType("application", "json"),
      ),
    );

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath("image", imageFile.path),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    _checkError(res);

    return CategoryResponse.fromJson(jsonDecode(res.body));
  }

  /* ================= UPDATE CATEGORY ================= */

  Future<CategoryResponse> updateCategory({
    required int id,
    required Map<String, dynamic> categoryData,
    File? imageFile,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/categories/$id");

    final request = http.MultipartRequest("PUT", uri);

    final headers = await _authService.headers(auth: true);
    request.headers.addAll(headers);

    request.files.add(
      http.MultipartFile.fromString(
        "category",
        jsonEncode(categoryData),
        contentType: http_parser.MediaType("application", "json"),
      ),
    );

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath("image", imageFile.path),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    _checkError(res);

    return CategoryResponse.fromJson(jsonDecode(res.body));
  }

  /* ================= DELETE CATEGORY ================= */

  Future<void> deleteCategory(int id) async {
    final res = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/categories/$id"),
      headers: await _authService.headers(auth: true),
    );

    _checkError(res);
  }

  /* ================= ERROR HANDLER ================= */

  void _checkError(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;

    try {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? "Server Error");
    } catch (_) {
      throw Exception("HTTP ${res.statusCode}");
    }
  }
}
