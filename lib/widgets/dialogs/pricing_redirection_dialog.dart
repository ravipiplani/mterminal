import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../reactive/blocs/user/user_bloc.dart';

void showPricingRedirectionDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return BlocConsumer<UserBloc, UserState>(listener: (context, state) {
          if (state is UserRetrievedState) {
            Get.offAllNamed(AppRouter.homePageRoute);
          }
        }, builder: (context, state) {
          return AlertDialog(
            icon: const Icon(Icons.payment),
            title: const Text('COMPLETE PAYMENT'),
            content:
                const Text('After completing the payment in browser, return here and refresh. If you have completed the payment, clock on Refresh button now.'),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                  onPressed: state is RetrievingUserState
                      ? null
                      : () {
                          BlocProvider.of<UserBloc>(context).add(GetUserEvent());
                        },
                  child: Text(state is RetrievingUserState ? 'REFRESHING...' : 'REFRESH'))
            ],
          );
        });
      });
}
