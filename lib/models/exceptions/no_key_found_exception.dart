class NoKeyFoundException implements Exception {
  NoKeyFoundException({String? message}) : message = message ?? 'No key found.';

  final String message;

  @override
  String toString() {
    return message;
  }
}
