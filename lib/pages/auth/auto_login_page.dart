import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../config/lottie_files.dart';
import '../../layout/device.dart';
import '../../reactive/blocs/authentication/authentication_bloc.dart';
import '../partials/status_view.dart';

class AutoLoginPage extends StatefulWidget {
  const AutoLoginPage({super.key, required this.refresh, required this.redirectTo});

  final String refresh;
  final String redirectTo;

  @override
  State<AutoLoginPage> createState() => _AutoLoginPageState();
}

class _AutoLoginPageState extends State<AutoLoginPage> {
  @override
  void initState() {
    BlocProvider.of<AuthenticationBloc>(context).add(RefreshTokenEvent(refresh: widget.refresh));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(listener: (context, state) async {
      if (state is TokenRefreshedState) {
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(widget.redirectTo);
      }
    }, builder: (context, state) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: state is TokenRefreshedState
              ? const StatusView(
                  lottie: LottieFiles.success,
                  title: 'Logged in successfully. Redirecting...',
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: Device.margin(context)),
                    Text('Logging in...', style: Theme.of(context).textTheme.headlineSmall)
                  ],
                ),
        ),
      );
    });
  }
}
