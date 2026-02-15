class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException() : super("Unauthorized request");
}

class NetworkException extends ApiException {
  NetworkException() : super("Network error occurred");
}
