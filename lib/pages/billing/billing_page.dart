import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app_router.dart';
import '../../config/endpoint.dart';
import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../models/invoice.dart';
import '../../reactive/blocs/billing/billing_bloc.dart';
import '../../utilities/helper.dart';
import '../../utilities/preferences.dart';
import '../../widgets/title_card.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  @override
  void initState() {
    BlocProvider.of<BillingBloc>(context).add(GetInvoicesEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(Device.margin(context)),
        child: Column(
          children: [_invoices],
        ),
      ),
    );
  }

  Widget get _invoices => TitleCard(
      title: 'Invoices',
      child: BlocBuilder<BillingBloc, BillingState>(builder: (context, state) {
        final invoices = <Invoice>[];
        if (state is InvoicesRetrievedState) {
          if (state.invoices.isEmpty) {
            return Text(
              'No new invoice available.',
              style: Theme.of(context).textTheme.titleMedium,
            );
          }
          invoices.addAll(state.invoices);
        }
        return ListView(
            shrinkWrap: true,
            children: invoices.map((invoice) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: GestureDetector(
                    onTap: invoice.url == null
                        ? null
                        : () {
                            Helper.openUrl(url: invoice.url!);
                          },
                    child: Text(
                      'Invoice #${invoice.number}',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline),
                    )),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Helper.displayAmount(invoice.amount)),
                    invoice.isPaid
                        ? Text('Paid on ${DateFormat(Keys.ddMMMMyHma).format(invoice.paidAt!.toLocal())}')
                        : Text('Due on ${DateFormat(Keys.ddMMMMyHma).format(invoice.dueOn.toLocal())}'),
                  ],
                ),
                isThreeLine: true,
                trailing: invoice.isPaid
                    ? TextButton(
                        onPressed: invoice.url == null
                            ? null
                            : () {
                                Helper.openUrl(url: invoice.url!);
                              },
                        child: const Text('View Invoice'))
                    : FilledButton.tonal(
                        onPressed: () {
                          if (kIsWeb) {
                            Get.toNamed(AppRouter.paymentInitiatePageRoute,
                                parameters: {Keys.subscriptionPlanId: invoice.subscriptionPlanId.toString(), Keys.invoiceId: invoice.id.toString()});
                          } else {
                            final uri = Uri.http(Endpoint.app, AppRouter.authAutoLoginPageRoute,
                                {Keys.refresh: Preferences.getString(Keys.refreshToken), Keys.redirectTo: AppRouter.homePageRoute});
                            Helper.openUrl(url: uri.toString());
                          }
                        },
                        child: const Text('Pay Now')),
              );
            }).toList());
      }));
}
