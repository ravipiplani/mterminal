import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'config/keys.dart';
import 'pages/auth/accept_team_invite_page.dart';
import 'pages/auth/auto_login_page.dart';
import 'pages/auth/email_verification_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/reset_password_link_page.dart';
import 'pages/auth/reset_password_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/auth/signup_success_page.dart';
import 'pages/device/device_page.dart';
import 'pages/home/home_page.dart';
import 'pages/pricing/payment_failure_page.dart';
import 'pages/pricing/payment_initiate_page.dart';
import 'pages/pricing/payment_success_page.dart';
import 'pages/pricing/pricing_page.dart';
import 'reactive/providers/app_provider.dart';
import 'utilities/preferences.dart';

class AppRouter {
  AppRouter._();

  static const homePageRoute = '/';
  static const devicePageRoute = '/devices';
  static const pricingPageRoute = '/pricing';
  static const paymentInitiatePageRoute = '/payment/initiate';
  static const paymentSuccessPageRoute = '/payment/success';
  static const paymentFailurePageRoute = '/payment/failure';
  static const authLoginPageRoute = '/auth/login';
  static const authAutoLoginPageRoute = '/auth/auto_login';
  static const authSignupPageRoute = '/auth/signup';
  static const authSignupSuccessPageRoute = '/auth/signup/success';
  static const authEmailVerificationPageRoute = '/auth/email_verification';
  static const authResetPasswordLinkPageRoute = '/auth/reset_password_link';
  static const authResetPasswordPageRoute = '/auth/reset_password';
  static const authTeamInvitePageRoute = '/auth/team_invite';

  static const unprotectedRoutes = [authLoginPageRoute, authSignupPageRoute, authSignupSuccessPageRoute];
}

Route<dynamic> generateRoute(RouteSettings settings) {
  final uriData = Uri.parse(settings.name ?? '');
  var path = uriData.path;

  // Redirect to home for unprotected routes
  if (AppRouter.unprotectedRoutes.contains(uriData.path) && _isLoggedIn) {
    path = AppRouter.homePageRoute;
  }

  if (_isLoggedIn && (_isDeviceLimitReached || _deviceTypeExists)) {
    path = AppRouter.devicePageRoute;
  }

  final queryParams = uriData.queryParameters;

  String? getQueryParam(String key) {
    return queryParams.containsKey(key) ? queryParams[key] : null;
  }

  switch (path) {
    case AppRouter.homePageRoute:
      final tab = getQueryParam(Keys.tab);
      return _getPageRoute(HomePage(tab: tab ?? 'home'), settings);
    case AppRouter.pricingPageRoute:
      return _getPageRoute(const PricingPage(), settings);
    case AppRouter.paymentInitiatePageRoute:
      final subscriptionPlanId = getQueryParam(Keys.subscriptionPlanId);
      final noOfSeats = getQueryParam(Keys.noOfSeats);
      final invoiceId = getQueryParam(Keys.invoiceId);
      final appleLineItemID = getQueryParam(Keys.appleLineItemID);
      if (subscriptionPlanId == null || noOfSeats == null) {
        return _redirectToHomePage();
      }
      return _getPageRoute(
          PaymentInitiatePage(
            subscriptionPlanId: int.parse(subscriptionPlanId),
            appleLineItemID: appleLineItemID,
            invoiceId: int.tryParse(invoiceId ?? ''),
            noOfSeats: int.parse(noOfSeats),
          ),
          settings);
    case AppRouter.paymentSuccessPageRoute:
      return _getPageRoute(const PaymentSuccessPage(), settings);
    case AppRouter.paymentFailurePageRoute:
      return _getPageRoute(const PaymentFailurePage(), settings);
    case AppRouter.authLoginPageRoute:
      return _getPageRoute(const LoginPage(), settings);
    case AppRouter.authAutoLoginPageRoute:
      final refresh = getQueryParam(Keys.refresh);
      final redirectTo = getQueryParam(Keys.redirectTo);
      if (refresh == null || redirectTo == null) {
        return _redirectToHomePage();
      }
      return _getPageRoute(AutoLoginPage(refresh: refresh, redirectTo: redirectTo), settings);
    case AppRouter.authSignupPageRoute:
      final email = getQueryParam(Keys.email);
      return _getPageRoute(SignupPage(email: email), settings);
    case AppRouter.authSignupSuccessPageRoute:
      return _getPageRoute(const SignupSuccessPage(), settings);
    case AppRouter.authEmailVerificationPageRoute:
      final uid = getQueryParam(Keys.uid);
      final token = getQueryParam(Keys.token);
      if (uid == null || token == null) {
        return _redirectToHomePage();
      }
      return _getPageRoute(EmailVerificationPage(uid: uid, token: token), settings);
    case AppRouter.authResetPasswordLinkPageRoute:
      return _getPageRoute(const ResetPasswordLinkPage(), settings);
    case AppRouter.authResetPasswordPageRoute:
      final uid = getQueryParam(Keys.uid);
      final token = getQueryParam(Keys.token);
      if (uid == null || token == null) {
        return _redirectToHomePage();
      }
      return _getPageRoute(ResetPasswordPage(uid: uid, token: token), settings);
    case AppRouter.authTeamInvitePageRoute:
      final iid = getQueryParam(Keys.iid);
      final uid = getQueryParam(Keys.uid);
      final token = getQueryParam(Keys.token);
      if (iid == null || uid == null || token == null) {
        return _redirectToHomePage();
      }
      return _getPageRoute(AcceptTeamInvitePage(iid: iid, uid: uid, token: token), settings);
    case AppRouter.devicePageRoute:
      return _getPageRoute(const DevicePage(), settings);
    default:
      return _redirectToHomePage();
  }
}

Route<dynamic> _redirectToHomePage() {
  return generateRoute(const RouteSettings(name: AppRouter.homePageRoute));
}

bool get _isLoggedIn => Get.context != null && Provider.of<AppProvider>(Get.context!, listen: false).isLoggedIn;

bool get _isDeviceLimitReached => Preferences.getBool(Keys.cannotAddMoreDevices) ?? false;

bool get _deviceTypeExists => Preferences.getBool(Keys.deviceTypeExists) ?? false;

PageRoute _getPageRoute(Widget child, RouteSettings settings) {
  return MaterialPageRoute(builder: (_) => child, settings: RouteSettings(name: settings.name));
}
