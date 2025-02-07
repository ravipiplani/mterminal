import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../config/lottie_files.dart';
import '../../widgets/logo.dart';
import '../partials/status_view.dart';

class SignupSuccessPage extends StatelessWidget {
  const SignupSuccessPage({super.key});

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
      body: StatusView(
        lottie: LottieFiles.success,
        title: 'Signed up successfully. Welcome to mTerminal.',
        description: 'An email with the confirmation link has been sent to you. Please confirm your email to get started.',
        buttonText: 'Login to Get Started',
        onPressed: () {
          Get.offAllNamed(AppRouter.authLoginPageRoute);
        },
      ),
    );
  }
}
