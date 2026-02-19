import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_config.dart';
import 'auth_service.dart';

class BrandService {
  final AuthService _authService = AuthService();

  /* ================= CREATE BRAND ================= */

  Future<Map<String, dynamic>> createBrand({
    required Map<String, dynamic> brandData,
    File? logoFile,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/brands");

    final request = http.MultipartRequest("POST", uri);

    final headers = await _authService.headers(auth: true);
    request.headers.addAll(headers);

    // ✅ JSON part (important for @RequestPart("brand"))
    request.files.add(
      http.MultipartFile.fromString(
        "brand",
        jsonEncode(brandData),
        contentType: MediaType('application', 'json'),
      ),
    );

    // ✅ Optional logo file
    if (logoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath("logo", logoFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _checkError(response);

    return jsonDecode(response.body);
  }

  /* ================= UPDATE BRAND ================= */

  Future<Map<String, dynamic>> updateBrand({
    required int id,
    required Map<String, dynamic> brandData,
    File? logoFile,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/brands/$id");

    final request = http.MultipartRequest("PUT", uri);

    final headers = await _authService.headers(auth: true);
    request.headers.addAll(headers);

    request.files.add(
      http.MultipartFile.fromString(
        "brand",
        jsonEncode(brandData),
        contentType: MediaType('application', 'json'),
      ),
    );

    if (logoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath("logo", logoFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _checkError(response);

    return jsonDecode(response.body);
  }

  /* ================= DELETE BRAND ================= */

  Future<void> deleteBrand(int id) async {
    final res = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/brands/$id"),
      headers: await _authService.headers(auth: true),
    );

    _checkError(res);
  }

  /* ================= GET BRAND BY ID ================= */

  Future<Map<String, dynamic>> getBrandById(int id) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/brands/$id"),
      headers: await _authService.headers(auth: true),
    );

    _checkError(res);

    return jsonDecode(res.body);
  }

  /* ================= GET ALL BRANDS ================= */

  Future<List<dynamic>> getAllBrands() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/brands"),
      headers: await _authService.headers(auth: true),
    );

    _checkError(res);

    return jsonDecode(res.body);
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
