import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'api_exceptions.dart';

class ApiClient {
  final Map<String, String> defaultHeaders = {
    "Content-Type": "application/json",
  };

  Future<dynamic> get(String endpoint) async {
    try {
      final res = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + endpoint),
        headers: defaultHeaders,
      );

      return _processResponse(res);
    } catch (_) {
      throw NetworkException();
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + endpoint),
        headers: defaultHeaders,
        body: jsonEncode(body),
      );

      return _processResponse(res);
    } catch (_) {
      throw NetworkException();
    }
  }

  dynamic _processResponse(http.Response res) {
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ApiException("Server error: ${res.statusCode}");
    }
  }
}
