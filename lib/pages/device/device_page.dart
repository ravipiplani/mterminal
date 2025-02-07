import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app_router.dart';
import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../models/app_device.dart';
import '../../reactive/blocs/app_device/app_device_bloc.dart';
import '../../reactive/blocs/authentication/authentication_bloc.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/preferences.dart';
import '../../widgets/gradient_container.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final cannotAddMoreDevices = Preferences.getBool(Keys.cannotAddMoreDevices) ?? true;
  final deviceTypeExists = Preferences.getBool(Keys.deviceTypeExists) ?? false;
  final DeviceType currentDeviceType = Platform.isAndroid || Platform.isIOS ? DeviceType.mobile : DeviceType.desktop;

  @override
  void initState() {
    BlocProvider.of<AppDeviceBloc>(context).add(GetAppDevicesEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: GradientContainer(
          child: Padding(
        padding: EdgeInsets.all(Device.margin(context)),
        child: Column(
          children: [
            BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  if (state is LoggedOutState) {
                    BlocProvider.of<AppDeviceBloc>(context).add(UpdateAppDeviceEvent());
                  }
                },
                child: Card(
                  child: ListTile(
                    title: Text(
                      deviceTypeExists ? 'Already logged in on similar device' : 'Device limit reached',
                      style: const TextStyle(color: Colors.red),
                    ),
                    subtitle: Text(deviceTypeExists
                        ? 'Log out from similar device type (${currentDeviceType.name}) to login to current device.'
                        : 'Log out from other devices to login to current device.'),
                  ),
                )),
            SizedBox(height: Device.margin(context)),
            BlocConsumer<AppDeviceBloc, AppDeviceState>(listener: (context, state) {
              if (state is AppDeviceUpdatedState) {
                Preferences.setBool(Keys.cannotAddMoreDevices, false);
                Preferences.setBool(Keys.deviceTypeExists, false);
                Get.offAllNamed(AppRouter.homePageRoute);
              } else if (state is UpdatingAppDeviceErrorState) {
                if (state.error != null) {
                  Preferences.setBool(Keys.cannotAddMoreDevices, state.error == AppDeviceError.cannotAddMoreDevices);
                  Preferences.setBool(Keys.deviceTypeExists, state.error == AppDeviceError.deviceTypeExists);
                  Get.offAllNamed(AppRouter.devicePageRoute);
                } else {
                  GetMterminal.snackBar(context, content: state.message);
                }
              }
            }, builder: (context, state) {
              final devices = <AppDevice>[];
              if (state is AppDevicesRetrievedState) {
                devices.addAll(state.appDevices);
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(Device.margin(context)),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(device.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Last used on ${DateFormat(Keys.ddMMMMyHma).format(device.lastActiveAt.toLocal())}'),
                        Text('Device Type: ${device.type.name.capitalizeFirst!}')
                      ],
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () {
                        _logOut(device);
                      },
                      child: const Text('Log Out'),
                    ),
                    titleAlignment: ListTileTitleAlignment.threeLine,
                    isThreeLine: true,
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              );
            }),
          ],
        ),
      )),
    );
  }

  void _logOut(AppDevice device) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setLogOutDialogState) {
            return AlertDialog(
              icon: const Icon(Icons.logout),
              title: const Text('Confirm Log Out?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    device.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Text('Please note if you have not synced your data from the above device, you may lose access to it.', style: TextStyle(color: Colors.red)),
                ],
              ),
              actions: [
                FilledButton(
                    onPressed: () {
                      BlocProvider.of<AuthenticationBloc>(context).add(LogOutEvent(token: device.token));
                      Get.back();
                    },
                    child: const Text('Log Out'))
              ],
            );
          });
        });
  }
}
