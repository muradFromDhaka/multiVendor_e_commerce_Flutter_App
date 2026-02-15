import 'package:multivendor_flutter_app/models/auth/user.dart';

class LoginResponse {
  final String jwtToken;
  final User user;

  LoginResponse({
    required this.jwtToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      jwtToken: json['jwtToken'],
      user: User.fromJson(json['user']),
    );
  }
}