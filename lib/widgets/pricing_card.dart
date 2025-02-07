import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../app_router.dart';
import '../config/keys.dart';
import '../layout/device.dart';
import '../models/license.dart';
import '../models/subscription_plan.dart';
import '../reactive/providers/app_provider.dart';
import '../utilities/get_mterminal.dart';
import 'dialogs/custom_licese_dialog.dart';

class PricingCard extends StatelessWidget {
  const PricingCard({super.key, this.showPrice = true, required this.subscriptionPlan});

  final bool showPrice;
  final SubscriptionPlan subscriptionPlan;

  @override
  Widget build(BuildContext context) {
    final watchAppProvider = context.watch<AppProvider>();
    License? activeLicense;
    try {
      activeLicense = GetMterminal.user().teams.first.activeLicense;
    } on Exception {
      activeLicense = null;
    }
    final isSubscriptionPlanActive = activeLicense != null && activeLicense.subscriptionPlan.id == subscriptionPlan.id;
    final cardColor = subscriptionPlan.costPerMonth != 0.0 ? Colors.green : null;

    return Padding(
      padding: EdgeInsets.all(Device.margin(context) * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subscriptionPlan.description,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: cardColor),
          ),
          if (showPrice) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  subscriptionPlan.planCostDisplay,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.black),
                ),
                Text(
                  ' / ${subscriptionPlan.costUnit}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: Device.margin(context) * 2),
            Text(
              subscriptionPlan.helpText1,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (subscriptionPlan.helpText2 != null)
              Text(
                subscriptionPlan.helpText2!,
                style: Theme.of(context).textTheme.bodySmall,
              )
          ],
          SizedBox(height: Device.margin(context)),
          if (watchAppProvider.isLoggedIn)
            FilledButton(
                onPressed: activeLicense != null && subscriptionPlan.sequence < activeLicense.subscriptionPlan.sequence
                    ? null
                    : () {
                        if (subscriptionPlan.isTeamPlan) {
                          showCustomLicenseDialog(context, subscriptionPlan);
                        } else if (subscriptionPlan.costPerMonth > 0.0) {
                          Get.toNamed(AppRouter.paymentInitiatePageRoute, parameters: {
                            Keys.subscriptionPlanId: subscriptionPlan.id.toString(),
                            Keys.appleLineItemID: subscriptionPlan.appleLineItemID.toString(),
                            Keys.noOfSeats: subscriptionPlan.isTeamPlan ? '0' : '1'
                          });
                        }
                      },
                style: FilledButton.styleFrom(backgroundColor: cardColor),
                child: Text(isSubscriptionPlanActive
                    ? activeLicense.subscriptionPlan.isTeamPlan
                        ? 'Buy More Seats'
                        : 'Active'
                    : 'Choose & Activate'))
          else if (subscriptionPlan.planCostDisplay.toLowerCase() == 'free')
            OutlinedButton(
                onPressed: () {
                  Get.toNamed(AppRouter.authSignupPageRoute);
                },
                child: const Text('Get Started'))
          else
            FilledButton(
                onPressed: () {
                  Get.toNamed(AppRouter.authSignupPageRoute);
                },
                child: const Text('Get Started')),
          SizedBox(height: Device.margin(context) * 2),
          ...subscriptionPlan.features.map((e) {
            final expandedValues = e.split(';');
            final isDisabled = expandedValues.length > 1 && expandedValues[1] == 'No';
            final values = expandedValues[0].split(':');
            return Container(
                margin: EdgeInsets.only(bottom: Device.margin(context)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDisabled)
                      const Icon(
                        Icons.cancel,
                        color: Colors.red,
                      )
                    else
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    SizedBox(width: Device.margin(context) / 2),
                    Text(values[0]),
                    if (values.length > 1)
                      Tooltip(
                          message: values[1],
                          child: const Icon(
                            Icons.info,
                            color: Colors.grey,
                          ))
                  ],
                ));
          }).toList()
        ],
      ),
    );
  }
}
