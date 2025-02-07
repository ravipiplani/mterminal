import 'dart:async' show Future;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

mixin AppStore {
  static const String _yearlyPlan = 'PROS';
  static const String _customPlan = 'PROM';

  static final List<String> _consumableProducts = [_customPlan];

  static late List<String> _kProductIds;
  static List<ProductDetails> products = [];
  static late InAppPurchase inAppPurchase;
  static late bool isAppStoreAvailable;
  static bool isAppleDevice = false;

  static Future<void> get initialize async {
    isAppleDevice = true;
    _kProductIds = [_yearlyPlan, _customPlan];
    inAppPurchase = InAppPurchase.instance;
    isAppStoreAvailable = await inAppPurchase.isAvailable();

    if (!isAppStoreAvailable) {
      return;
    }

    if (Platform.isIOS) {
      var iosPlatformAddition = inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse = await inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      return;
    }

    products = productDetailResponse.productDetails;

    final paymentWrapper = SKPaymentQueueWrapper();
    final transactions = await paymentWrapper.transactions();
    for (final transaction in transactions) {
      if (transaction.payment.productIdentifier == 'PROS') {
        // print('transaction $transaction');
        await paymentWrapper.finishTransaction(transaction);
      }
    }
  }

  static Future<void> handlePurchases(
      {required List<PurchaseDetails> purchaseDetails, required Function(PurchaseDetails) onSuccess, required VoidCallback onFailure}) async {
    for (final purchaseDetail in purchaseDetails) {
      if (!_kProductIds.contains(purchaseDetail.productID)) {
        continue;
      }
      if (purchaseDetail.status == PurchaseStatus.pending) {
        // showPendingUI();
      } else {
        if (purchaseDetail.status == PurchaseStatus.error || purchaseDetail.status == PurchaseStatus.canceled) {
          if (purchaseDetail.pendingCompletePurchase) {
            inAppPurchase.completePurchase(purchaseDetail);
          }
          onFailure();
        } else if (purchaseDetail.status == PurchaseStatus.purchased || purchaseDetail.status == PurchaseStatus.restored) {
          if (purchaseDetail.pendingCompletePurchase) {
            AppStore.inAppPurchase.completePurchase(purchaseDetail);
          }
          onSuccess(purchaseDetail);
        }
      }
    }
  }

  static bool isConsumable(String productId) {
    return _consumableProducts.contains(productId);
  }
}

/// Example implementation of the
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implementated to provide information
/// needed to complete transactions.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
