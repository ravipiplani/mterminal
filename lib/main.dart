import 'dart:io';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart' as firebase_analytics;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app_router.dart';
import 'config/constants.dart';
import 'config/keys.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'reactive/blocs/app_device/app_device_bloc.dart';
import 'reactive/blocs/authentication/authentication_bloc.dart';
import 'reactive/blocs/billing/billing_bloc.dart';
import 'reactive/blocs/credential/credential_bloc.dart';
import 'reactive/blocs/payment/payment_bloc.dart';
import 'reactive/blocs/secure_share/secure_share_bloc.dart';
import 'reactive/blocs/subscription_plan/subscription_plan_bloc.dart';
import 'reactive/blocs/tag/tag_bloc.dart';
import 'reactive/blocs/team/team_bloc.dart';
import 'reactive/blocs/user/user_bloc.dart';
import 'reactive/providers/app_provider.dart';
import 'reactive/providers/local_terminal_page_provider.dart';
import 'utilities/analytics.dart';
import 'utilities/app_identifier.dart';
import 'utilities/app_store.dart';
import 'utilities/db.dart';
import 'utilities/preferences.dart';
import 'utilities/user_device.dart';
import 'widgets/platform_impl/url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await AppIdentifier.initialize;
  }

  await Preferences.instance;

  await _setupFirebase();

  if (!kIsWeb) {
    await DB.initialize;
    if (Preferences.containsKey(Keys.accessToken) && Preferences.getString(Keys.accessToken).isNotEmpty) {
      await UserDevice.update();
    }
  }

  if (!kIsWeb && (Platform.isMacOS || Platform.isIOS)) {
    await AppStore.initialize;
  }

  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    if (_isDesktop) {
      // _setupAcrylic();
      final view = PlatformDispatcher.instance.views.first;
      final size = view.physicalSize;
      final ratio = view.devicePixelRatio;
      final width = size.width / ratio;
      final windowOptions = WindowOptions(
          size: Size(max(width, 1200), size.height),
          minimumSize: const Size(600, 400),
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.hidden,
          center: true);
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  usePathUrlStrategy();
  runApp(const MTerminalApp());
}

bool get _isDesktop {
  if (kIsWeb) {
    return false;
  }
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

Future<void> _setupAcrylic() async {
  await Window.initialize();
  Window.enterFullscreen();
  Window.showTitle();
}

Future<void> _setupFirebase() async {
  // Initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // setup analytics
  await Analytics.initialize();

  // setup remote config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(seconds: 60),
  ));
  await remoteConfig.fetchAndActivate();
  if (!kIsWeb) {
    remoteConfig.onConfigUpdated.listen((event) async {
      await remoteConfig.activate();
    });
  }

  // setup crashlytics
  if (!kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}

class MTerminalApp extends StatefulWidget {
  const MTerminalApp({super.key});

  @override
  State<MTerminalApp> createState() => _MTerminalAppState();
}

class _MTerminalAppState extends State<MTerminalApp> with WindowListener {
  static final observer = firebase_analytics.FirebaseAnalyticsObserver(analytics: Analytics.instance);

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(create: (context) => AuthenticationBloc()),
        BlocProvider<PaymentBloc>(create: (context) => PaymentBloc()),
        BlocProvider<SubscriptionPlanBloc>(create: (context) => SubscriptionPlanBloc()),
        BlocProvider<AppDeviceBloc>(create: (context) => AppDeviceBloc()),
        BlocProvider<BillingBloc>(create: (context) => BillingBloc()),
        BlocProvider<UserBloc>(create: (context) => UserBloc()),
        BlocProvider<SecureShareBloc>(create: (context) => SecureShareBloc()),
        BlocProvider<TeamBloc>(create: (context) => TeamBloc()),
        BlocProvider<TagBloc>(create: (context) => TagBloc()),
        BlocProvider<CredentialBloc>(create: (context) => CredentialBloc()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AppProvider()),
          ChangeNotifierProvider(create: (context) => LocalTerminalPageProvider()),
        ],
        child: GetMaterialApp(
          title: kAppName,
          theme: kLightTheme,
          // darkTheme: kDarkTheme,
          debugShowCheckedModeBanner: false,
          navigatorObservers: <NavigatorObserver>[observer],
          // home: const SignupSuccessPage(),
          onGenerateRoute: generateRoute,
          onUnknownRoute: generateRoute,
          // shortcuts: ,
        ),
      ),
    );
  }
}
