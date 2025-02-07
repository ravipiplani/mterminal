import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../config/lottie_files.dart';
import '../../widgets/gradient_container.dart';
import '../../widgets/logo.dart';
import '../partials/status_view.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: const Logo(),
          centerTitle: false,
          automaticallyImplyLeading: false,
        ),
        body: StatusView(
          lottie: LottieFiles.paymentSuccess,
          title: 'Payment successful.',
          buttonText: 'Continue to Home',
          onPressed: () {
            Get.offAllNamed(AppRouter.homePageRoute);
          },
        ),
      ),
    );
  }
}
