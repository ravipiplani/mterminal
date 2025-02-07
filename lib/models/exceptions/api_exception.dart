class ApiException implements Exception {
  ApiException(String? message) : message = message ?? 'Something went wrong!';

  final String message;

  @override
  String toString() {
    return message;
  }
}
