import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../models/app_device.dart';
import '../../../models/exceptions/cannot_add_device_exception.dart';
import '../../../models/exceptions/device_type_exists_exception.dart';
import '../../../services/app_device_service.dart';
import '../../../utilities/user_device.dart';

part 'app_device_event.dart';
part 'app_device_state.dart';

class AppDeviceBloc extends Bloc<AppDeviceEvent, AppDeviceState> {
  AppDeviceBloc() : super(UninitializedState()) {
    on<GetAppDevicesEvent>(_onGetAppDevicesEvent);
    on<UpdateAppDeviceEvent>(_onUpdateAppDeviceEvent);
  }

  final _appDeviceService = AppDeviceService();

  AppDeviceState get initialState => UninitializedState();

  Future<void> _onGetAppDevicesEvent(GetAppDevicesEvent event, Emitter<AppDeviceState> emit) async {
    emit(RetrievingAppDevicesState());
    try {
      final appDevices = await _appDeviceService.get();
      emit(AppDevicesRetrievedState(appDevices: appDevices));
    } on Exception catch (e) {
      emit(RetrievingAppDevicesErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateAppDeviceEvent(UpdateAppDeviceEvent event, Emitter<AppDeviceState> emit) async {
    emit(UpdatingAppDeviceState());
    try {
      final deviceData = await UserDevice.data();
      final appDevice = await _appDeviceService.update(data: deviceData);
      emit(AppDeviceUpdatedState(appDevice: appDevice));
    } on CannotAddDeviceException catch (e) {
      emit(UpdatingAppDeviceErrorState(message: e.toString(), error: AppDeviceError.cannotAddMoreDevices));
    } on DeviceTypeExistsException catch (e) {
      emit(UpdatingAppDeviceErrorState(message: e.toString(), error: AppDeviceError.deviceTypeExists));
    } on Exception catch (e) {
      emit(UpdatingAppDeviceErrorState(message: e.toString()));
    }
  }
}
