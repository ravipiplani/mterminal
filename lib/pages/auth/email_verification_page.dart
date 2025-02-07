import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../config/lottie_files.dart';
import '../../reactive/blocs/authentication/authentication_bloc.dart';
import '../../widgets/logo.dart';
import '../partials/status_view.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key, required this.uid, required this.token});

  final String uid;
  final String token;

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  @override
  void initState() {
    BlocProvider.of<AuthenticationBloc>(context).add(VerifyEmailEvent(uid: widget.uid, token: widget.token));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        title: const Logo(),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(builder: (context, state) {
        if (state is EmailVerifiedState) {
          return StatusView(
            lottie: LottieFiles.success,
            title: 'Email verified successfully.',
            buttonText: 'Go to Home',
            onPressed: () {
              Get.offAllNamed(AppRouter.homePageRoute);
            },
          );
        } else if (state is VerifyingEmailErrorState) {
          return StatusView(
            lottie: LottieFiles.error,
            title: 'Email verification failed.',
            description: state.message,
            buttonText: 'Go to Home',
            onPressed: () {
              Get.offAllNamed(AppRouter.homePageRoute);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
