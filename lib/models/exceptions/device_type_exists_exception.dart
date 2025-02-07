class DeviceTypeExistsException implements Exception {
  DeviceTypeExistsException({String? message}) : message = message ?? 'Device type already exists.';

  final String message;

  @override
  String toString() {
    return message;
  }
}
