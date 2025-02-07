import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../config/lottie_files.dart';
import '../../reactive/providers/app_provider.dart';
import '../../widgets/gradient_container.dart';
import '../../widgets/logo.dart';
import '../partials/status_view.dart';

class PaymentFailurePage extends StatelessWidget {
  const PaymentFailurePage({super.key});

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
          lottie: LottieFiles.error,
          title: 'Payment failed. Please try again.',
          buttonText: 'Go to Billing',
          onPressed: () {
            context.read<AppProvider>().selectedNavigationRailIndex = kIsWeb ? 1 : 5;
            Get.offAllNamed(AppRouter.homePageRoute);
          },
        ),
      ),
    );
  }
}
