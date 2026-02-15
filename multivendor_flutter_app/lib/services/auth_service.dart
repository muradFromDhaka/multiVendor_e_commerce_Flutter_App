// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:multivendor_flutter_app/models/auth/RegisterRequest.dart';
// import 'package:multivendor_flutter_app/services/api_config.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   Future<bool> login(String username, String password) async {
//     final res = await http.post(
//       Uri.parse("${ApiConfig.baseUrl}/auth/signin"),
//       headers: await headers(),
//       body: jsonEncode({"username": username, "password": password}),
//     );

//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       final token = data['jwtToken'];

//       if (token != null && token.isNotEmpty) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('jwtToken', token);
//         return true;
//       }
//     }

//     return false;
//   }

//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('jwtToken');
//   }

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('jwtToken');
//   }

//   Future<Map<String, String>> headers({bool auth = false}) async {
//     final token = await getToken();
//     if (auth && (token == null || token.isEmpty)) {
//       throw Exception("No JWT token found. Please login first.");
//     }

//     final headers = <String, String>{
//       "Content-Type": "application/json",
//       if (auth) "Authorization": "Bearer $token",
//     };

//     return headers;
//   }

//   // ================= REGISTER =================

//   Future<bool> register(Registration request) async {
//     final res = await http.post(
//       Uri.parse("${ApiConfig.baseUrl}/auth/signup"),
//       headers: await headers(),
//       body: jsonEncode(request.toJson()),
//     );
//     return res.statusCode == 200 || res.statusCode == 201;
//   }

//   // Future<Map<String, String>> headers({
//   //   bool auth = false,
//   //   bool isMultipart = false,
//   // }) async {
//   //   final token = await getToken();

//   //   if (auth && (token == null || token.isEmpty)) {
//   //     throw Exception("No JWT token found. Please login first.");
//   //   }

//   //   final headers = <String, String>{
//   //     if (!isMultipart) "Content-Type": "application/json",
//   //     if (auth) "Authorization": "Bearer $token",
//   //   };

//   //   return headers;
//   // }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multivendor_flutter_app/models/auth/RegisterRequest.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';

class AuthService {
  static const _tokenKey = "jwtToken";

  // ================= LOGIN =================

  Future<bool> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/auth/signin"),
        headers: await headers(),
        body: jsonEncode({"username": username, "password": password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['jwtToken'];

        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          return true;
        }
      }

      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  // ================= REGISTER =================

  Future<bool> register(Registration request) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/auth/signup"),
        headers: await headers(),
        body: jsonEncode(request),
      );

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return false;
    }
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ================= TOKEN =================

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ================= HEADERS =================

  Future<Map<String, String>> headers({bool auth = false}) async {
    final token = await getToken();

    if (auth && (token == null || token.isEmpty)) {
      throw Exception("No JWT token found");
    }

    return {
      "Content-Type": "application/json",
      if (auth) "Authorization": "Bearer $token",
    };
  }

  // ================= JWT PARSE =================

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception("Invalid JWT Token");
    }

    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));

    return jsonDecode(decoded);
  }

  // ================= TOKEN EXPIRY =================

  bool _isTokenExpired(Map<String, dynamic> jwt) {
    if (!jwt.containsKey('exp')) return false;

    final exp = jwt['exp'] * 1000; // seconds → ms
    return DateTime.now().millisecondsSinceEpoch > exp;
  }

  // ================= CURRENT USER =================

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final jwt = _parseJwt(token);

      if (_isTokenExpired(jwt)) {
        await logout();
        return null;
      }

      return {
        "userName": jwt['sub'],
        "email": jwt['email'],
        "userFirstName": jwt['userFirstName'],
        "userLastName": jwt['userLastName'],
        "roles": List<String>.from(jwt['roles'] ?? []),
      };
    } catch (e) {
      print("TOKEN PARSE ERROR: $e");
      await logout();
      return null;
    }
  }

  // ================= ROLE CHECK =================

  Future<bool> hasRole(String roleName) async {
    final user = await getCurrentUser();
    if (user == null) return false;

    final roles = List<String>.from(user['roles'] ?? []);
    return roles.contains(roleName);
  }

  // ================= SESSION RESTORE =================

  Future<bool> restoreSession() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final jwt = _parseJwt(token);

      if (_isTokenExpired(jwt)) {
        await logout();
        return false;
      }

      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }
}
