import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../layout/device.dart';
import '../../reactive/blocs/subscription_plan/subscription_plan_bloc.dart';
import '../../reactive/providers/app_provider.dart';
import '../../widgets/gradient_container.dart';
import '../../widgets/logo.dart';
import '../../widgets/mterminal_bottom_app_bar.dart';
import '../../widgets/pricing_card.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  late AppProvider _watchAppProvider;
  late double _margin;

  @override
  void initState() {
    BlocProvider.of<SubscriptionPlanBloc>(context).add(GetSubscriptionPlansEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _margin = Device.margin(context);
    _watchAppProvider = context.watch<AppProvider>();
    return Scaffold(
      // backgroundColor: Colors.white,
      floatingActionButton: _watchAppProvider.isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.back();
              },
              label: const Text('My Account'),
              icon: const Icon(Icons.verified_user))
          : FloatingActionButton.extended(
              onPressed: () {
                Get.toNamed(AppRouter.authSignupPageRoute);
              },
              label: const Text('Sign Up'),
              icon: const Icon(Icons.arrow_forward)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: const MTerminalBottomAppBar(),
      body: SafeArea(
        child: GradientContainer(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_margin),
            child: Device(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Logo(),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: _margin * 2),
                    child: Text(
                      'Try mTerminal for free. Forever.',
                      style: Device.isDesktop(context) ? Theme.of(context).textTheme.displaySmall : Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: _margin),
                    child: Text(
                      'Or buy a perpetual license for professionals. No subscriptions attached.',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: _margin * 2),
                  BlocBuilder<SubscriptionPlanBloc, SubscriptionPlanState>(builder: (context, state) {
                    if (state is RetrievingSubscriptionPlansState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SubscriptionPlansRetrievedState) {
                      return GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: Device.isDesktop(context) ? 3 : 1,
                          childAspectRatio: Device.isDesktop(context) ? 0.6 : 1.2,
                          crossAxisSpacing: _margin,
                          mainAxisSpacing: _margin,
                          physics: const NeverScrollableScrollPhysics(),
                          children: state.subscriptionPlans.map((subscriptionPlan) {
                            return Card(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Device.isDesktop(context) ? _margin : 0, vertical: Device.isDesktop(context) ? 0 : _margin),
                                child: PricingCard(subscriptionPlan: subscriptionPlan),
                              ),
                            );
                          }).toList());
                    } else if (state is RetrievingSubscriptionPlansErrorState) {
                      return ErrorWidget(Exception(state.message));
                    }
                    return Container();
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
