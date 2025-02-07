part of 'app_device_bloc.dart';

abstract class AppDeviceState {
  AppDeviceState();
}

class UninitializedState extends AppDeviceState {}

//Retrieve App Devices
class RetrievingAppDevicesState extends AppDeviceState {}

class AppDevicesRetrievedState extends AppDeviceState {
  AppDevicesRetrievedState({required this.appDevices});

  final List<AppDevice> appDevices;

  List<Object> get props => [appDevices];
}

class RetrievingAppDevicesErrorState extends AppDeviceState {
  RetrievingAppDevicesErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}

//Update App Device
class UpdatingAppDeviceState extends AppDeviceState {}

class AppDeviceUpdatedState extends AppDeviceState {
  AppDeviceUpdatedState({required this.appDevice});

  final AppDevice appDevice;

  List<Object> get props => [appDevice];
}

enum AppDeviceError { cannotAddMoreDevices, deviceTypeExists }

class UpdatingAppDeviceErrorState extends AppDeviceState {
  UpdatingAppDeviceErrorState({required this.message, this.error});

  final String message;
  final AppDeviceError? error;

  List<Object> get props => [message];
}
