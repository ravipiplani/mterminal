part of 'app_device_bloc.dart';

abstract class AppDeviceEvent {}

class UninitializedEvent extends AppDeviceEvent {}

class GetAppDevicesEvent extends AppDeviceEvent {}

class UpdateAppDeviceEvent extends AppDeviceEvent {}
