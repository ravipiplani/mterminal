import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_router.dart';
import '../layout/device.dart';
import 'title_card.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loginOnTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Get.toNamed(AppRouter.authLoginPageRoute);
      };
    return Container(
      padding: EdgeInsets.all(Device.margin(context)),
      width: Device.isDesktop(context) ? Device.column(context) * 4 : null,
      child: TitleCard(
          color: Colors.transparent,
          title: 'GET STARTED',
          desc: 'Start using mTerminal with your team.',
          isDark: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppRouter.authSignupPageRoute);
                },
                child: const Text('SIGN UP'),
              ),
              SizedBox(height: Device.margin(context)),
              RichText(
                  text: TextSpan(text: 'Already have an account? ', children: [
                TextSpan(
                    mouseCursor: SystemMouseCursors.click,
                    recognizer: loginOnTapRecognizer,
                    text: 'Login',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondaryContainer, fontWeight: FontWeight.bold))
              ]))
            ],
          )),
    );
  }
}
