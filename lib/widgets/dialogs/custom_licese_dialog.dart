import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../models/subscription_plan.dart';
import '../../utilities/get_mterminal.dart';

void showCustomLicenseDialog(BuildContext context, SubscriptionPlan subscriptionPlan) {
  showDialog(
      context: context,
      builder: (dialogContext) {
        final license = GetMterminal.activeLicense();
        final minimumNoOfSeats = license.subscriptionPlan.isTeamPlan ? 1.0 : 2.0;
        int noOfSeats = minimumNoOfSeats.toInt();
        double amount = subscriptionPlan.costPerMonth * minimumNoOfSeats;
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            icon: const Icon(Icons.event_seat),
            title: const Text('Buy more seats'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider.adaptive(
                    value: noOfSeats.toDouble(),
                    min: 1,
                    max: 50,
                    divisions: 50,
                    onChanged: (value) {
                      final seats = value < minimumNoOfSeats ? minimumNoOfSeats.toInt() : value.toInt();
                      setDialogState(() {
                        noOfSeats = seats;
                        amount = subscriptionPlan.costPerMonth * noOfSeats;
                      });
                    }),
                Text(
                  noOfSeats.toString(),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                SizedBox(height: Device.margin(context)),
                FilledButton(
                    onPressed: () {
                      Get.toNamed(AppRouter.paymentInitiatePageRoute, parameters: {
                        Keys.subscriptionPlanId: subscriptionPlan.id.toString(),
                        Keys.noOfSeats: noOfSeats.toString(),
                        Keys.appleLineItemID: subscriptionPlan.appleLineItemID.toString(),
                      });
                    },
                    child: Text('Pay $amount + 18% GST')),
                SizedBox(height: Device.margin(context)),
                Text(
                  'To switch to custom license, you need to buy minimum $minimumNoOfSeats seats.',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          );
        });
      });
}
