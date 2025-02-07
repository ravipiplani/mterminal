import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../reactive/blocs/app_device/app_device_bloc.dart';
import '../../reactive/blocs/authentication/authentication_bloc.dart';
import '../../utilities/analytics.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/preferences.dart';
import '../../widgets/button_loader.dart';
import '../../widgets/logo.dart';
import '../../widgets/mterminal_bottom_app_bar.dart';
import '../../widgets/obscure_visibility_icon.dart';
import '../../widgets/widget_helper.dart';

enum LoginStep { email, password }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.source});

  final String? source;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _fbKeyLogIn = GlobalKey<FormBuilderState>();
  late LoginStep _currentStep;
  final _passwordFocusNode = FocusNode(debugLabel: 'password');
  late bool _obscurePassword;

  @override
  void initState() {
    _currentStep = LoginStep.email;
    _obscurePassword = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Logo(redirectToWebsite: kIsWeb),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Device.isMobile(context) ? Device.margin(context) : 0),
          child: Center(
            heightFactor: 1.0,
            child: SizedBox(
              width: Device.isMobile(context) ? Device.width(context) : Device.width(context) / 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: Device.column(context)),
                  Text('Sign In to mTerminal', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black)),
                  SizedBox(height: Device.margin(context) * 2),
                  _loginForm(),
                  SizedBox(height: Device.margin(context) * 2),
                  TextButton(
                      onPressed: () {
                        Get.toNamed(AppRouter.authResetPasswordLinkPageRoute);
                      },
                      child: const Text('RESET YOUR PASSWORD')),
                  Divider(color: Theme.of(context).colorScheme.surfaceVariant, height: Device.margin(context) * 4),
                  const Text('Are you a new user?'),
                  SizedBox(height: Device.margin(context)),
                  ElevatedButton(
                      onPressed: () {
                        Get.toNamed(AppRouter.authSignupPageRoute);
                      },
                      child: const Text('CREATE ACCOUNT'))
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MTerminalBottomAppBar(),
    );
  }

  Widget _loginForm() {
    return BlocConsumer<AppDeviceBloc, AppDeviceState>(listener: (context, appDeviceState) {
      if (appDeviceState is AppDeviceUpdatedState) {
        Preferences.setBool(Keys.cannotAddMoreDevices, false);
        Preferences.setBool(Keys.deviceTypeExists, false);
        Get.offAllNamed(AppRouter.homePageRoute);
      } else if (appDeviceState is UpdatingAppDeviceErrorState) {
        if (appDeviceState.error != null) {
          Preferences.setBool(Keys.cannotAddMoreDevices, appDeviceState.error == AppDeviceError.cannotAddMoreDevices);
          Preferences.setBool(Keys.deviceTypeExists, appDeviceState.error == AppDeviceError.deviceTypeExists);
          Get.offAllNamed(AppRouter.devicePageRoute);
        } else {
          GetMterminal.snackBar(context, content: appDeviceState.message);
        }
      }
    }, builder: (context, appDeviceState) {
      return BlocConsumer<AuthenticationBloc, AuthenticationState>(listener: (context, state) {
        if (state is LoggedInState) {
          Analytics.logLogin();
          Analytics.setUser(user: GetMterminal.user());
          if (kIsWeb) {
            Get.offAllNamed(AppRouter.homePageRoute);
          } else {
            BlocProvider.of<AppDeviceBloc>(context).add(UpdateAppDeviceEvent());
          }
        }
        if (state is LoggingInErrorState) {
          GetMterminal.snackBar(context, content: 'Please check if you are entering the correct email and password.');
        }
      }, builder: (context, state) {
        return FormBuilder(
          key: _fbKeyLogIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilderTextField(
                name: Keys.email,
                decoration: const InputDecoration(label: Text('EMAIL')),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
                onSubmitted: (value) {
                  _validateEmail();
                },
              ),
              if (_currentStep == LoginStep.password)
                FadeIn(
                  animate: true,
                  child: Padding(
                    padding: EdgeInsets.only(top: Device.margin(context)),
                    child: FormBuilderTextField(
                      name: Keys.password,
                      obscureText: _obscurePassword,
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                          label: const Text('PASSWORD'),
                          suffixIcon: ObscureVisibilityIcon(
                            isObscure: _obscurePassword,
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          )),
                      focusNode: _passwordFocusNode,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      onSubmitted: (value) {
                        _tryLogin();
                      },
                    ),
                  ),
                ),
              SizedBox(height: Device.margin(context) * 2),
              ButtonLoader(
                isLoading: state is LoggingInState,
                width: double.infinity,
                child: FilledButton(
                    style: state is LoggingInState || appDeviceState is UpdatingAppDeviceState ? WidgetHelper.buttonStyleWhenLoading : null,
                    onPressed: state is LoggingInState || appDeviceState is UpdatingAppDeviceState
                        ? null
                        : () {
                            if (_currentStep == LoginStep.email) {
                              _validateEmail();
                            } else if (_currentStep == LoginStep.password) {
                              _tryLogin();
                            }
                          },
                    child: const Text('CONTINUE')),
              ),
            ],
          ),
        );
      });
    });
  }

  void _validateEmail() {
    if (_fbKeyLogIn.currentState!.fields[Keys.email]?.validate() ?? false) {
      setState(() {
        _currentStep = LoginStep.password;
      });
      _passwordFocusNode.requestFocus();
    }
  }

  void _tryLogin() {
    if (_fbKeyLogIn.currentState!.saveAndValidate()) {
      final values = _fbKeyLogIn.currentState!.value;
      BlocProvider.of<AuthenticationBloc>(context).add(LogInEvent(email: values[Keys.email], password: values[Keys.password]));
    }
  }
}
