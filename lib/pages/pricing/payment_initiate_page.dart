import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:lottie/lottie.dart';

import '../../app_router.dart';
import '../../config/keys.dart';
import '../../config/lottie_files.dart';
import '../../models/payment_order.dart';
import '../../reactive/blocs/payment/payment_bloc.dart';
import '../../services/user_service.dart';
import '../../utilities/app_store.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/payment_gateway/payment_gateway.dart';
import '../../widgets/gradient_container.dart';
import '../partials/status_view.dart';

class PaymentInitiatePage extends StatefulWidget {
  const PaymentInitiatePage({super.key, required this.subscriptionPlanId, this.invoiceId, required this.noOfSeats, this.appleLineItemID});

  final int subscriptionPlanId;
  final String? appleLineItemID;
  final int noOfSeats;
  final int? invoiceId;

  @override
  State<PaymentInitiatePage> createState() => _PaymentInitiatePageState();
}

class _PaymentInitiatePageState extends State<PaymentInitiatePage> {
  late int _gateway;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late PaymentOrder _paymentOrder;

  @override
  void initState() {
    _gateway = AppStore.isAppleDevice ? 2 : 1;

    if (AppStore.isAppleDevice) {
      _initializeInAppPurchase();
    }

    BlocProvider.of<PaymentBloc>(context).add(
        CreatePaymentOrderEvent(gateway: _gateway, subscriptionPlanId: widget.subscriptionPlanId, invoiceId: widget.invoiceId, noOfSeats: widget.noOfSeats));
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(listener: (context, state) async {
      if (state is CreatingPaymentOrderErrorState) {
        GetMterminal.snackBar(context, content: state.message);
        Get.back();
      }
      if (state is PaymentOrderCreatedState) {
        _paymentOrder = state.paymentOrder;
        if (state.paymentOrder.gateway == Gateway.apple) {
          final productDetails = AppStore.products.firstWhere((element) => element.id == widget.appleLineItemID);
          final purchaseParam =
              AppStorePurchaseParam(productDetails: productDetails, applicationUserName: GetMterminal.user().uuid, quantity: widget.noOfSeats);
          if (AppStore.isConsumable(productDetails.id)) {
            AppStore.inAppPurchase.buyConsumable(purchaseParam: purchaseParam).catchError(_handleStoreBuyError);
          } else {
            AppStore.inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam).catchError(_handleStoreBuyError);
          }
        } else {
          final paymentGateway = PaymentGateway(
              context: context,
              type: PaymentGatewayType.razorpay,
              gatewayKey: state.paymentOrder.key,
              amount: state.paymentOrder.amount,
              currency: state.paymentOrder.currency,
              onSuccess: (orderId, paymentId, signature) {
                BlocProvider.of<PaymentBloc>(context)
                    .add(CapturePaymentEvent(transactionId: _paymentOrder.id, data: {Keys.paymentId: paymentId, Keys.signature: signature}));
              });
          paymentGateway.openGateway(token: state.paymentOrder.orderId!);
        }
      }
      if (state is PaymentCapturedState) {
        await UserService().me();
        Get.offAllNamed(AppRouter.paymentSuccessPageRoute);
      }
    }, builder: (context, state) {
      return Scaffold(body: GradientContainer(child: Center(child: _body(state))));
    });
  }

  Widget _body(PaymentState state) {
    if (state is CapturingPaymentErrorState) {
      return StatusView(
        lottie: LottieFiles.error,
        title: state.message,
        buttonText: 'Go to Home',
        onPressed: () {
          Get.offAllNamed(AppRouter.homePageRoute);
        },
      );
    } else if (state is PaymentCapturedState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [LottieBuilder.asset(LottieFiles.paymentSuccess, height: 200, repeat: false), const Text('Redirecting...')],
      );
    } else {
      return const StatusView(
        lottie: LottieFiles.loader,
        title: 'Payment in progress..',
      );
    }
  }

  void _initializeInAppPurchase() {
    final Stream<List<PurchaseDetails>> purchaseStream = AppStore.inAppPurchase.purchaseStream;
    _subscription = purchaseStream.listen((purchaseDetails) {
      AppStore.handlePurchases(
          purchaseDetails: purchaseDetails,
          onSuccess: (purchaseDetail) {
            BlocProvider.of<PaymentBloc>(context).add(CapturePaymentEvent(
                transactionId: _paymentOrder.id,
                data: {Keys.paymentId: purchaseDetail.purchaseID!, Keys.signature: purchaseDetail.verificationData.serverVerificationData}));
          },
          onFailure: () {
            Get.offAllNamed(AppRouter.paymentFailurePageRoute);
          });
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _subscription.resume();
    });
  }

  bool _handleStoreBuyError(dynamic err) {
    var errorMessage = 'Something went wrong. Please try again.';
    if (err.code == 'storekit_duplicate_product_object') {
      errorMessage = 'There is already a purchase in progress. Please try again. Thanks';
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(Icons.warning),
            title: const Text('Purchase Failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.offAllNamed(AppRouter.homePageRoute, parameters: {Keys.tab: 'settings'});
                  },
                  child: const Text('Go to Settings tab'))
            ],
          );
        });
    return true;
  }
}
