class CannotAddDeviceException implements Exception {
  CannotAddDeviceException({String? message}) : message = message ?? 'Cannot add more devices on the subscribed plan.';

  final String message;

  @override
  String toString() {
    return message;
  }
}
