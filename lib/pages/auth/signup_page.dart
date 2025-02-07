import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

import '../../app_router.dart';
import '../../config/colors.dart';
import '../../config/endpoint.dart';
import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../reactive/blocs/authentication/authentication_bloc.dart';
import '../../utilities/analytics.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/helper.dart';
import '../../widgets/button_loader.dart';
import '../../widgets/logo.dart';
import '../../widgets/mterminal_bottom_app_bar.dart';
import '../../widgets/obscure_visibility_icon.dart';
import '../../widgets/widget_helper.dart';

enum SignUpStep { email, password }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, this.email});

  final String? email;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _fbKeySignUp = GlobalKey<FormBuilderState>();
  final passNotifier = ValueNotifier<PasswordStrength?>(null);
  late SignUpStep _currentStep;
  late bool _obscurePassword;

  late GestureRecognizer _termsOfUseOnTapRecognizer;
  late GestureRecognizer _privacyPolicyOnTapRecognizer;

  @override
  void initState() {
    _currentStep = SignUpStep.email;
    _obscurePassword = true;
    _termsOfUseOnTapRecognizer = TapGestureRecognizer()..onTap = _openTermsOfUse;
    _privacyPolicyOnTapRecognizer = TapGestureRecognizer()..onTap = _openPrivacyPolicy;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        title: const Logo(redirectToWebsite: kIsWeb),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
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
                    Text('Welcome to mTerminal', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black)),
                    SizedBox(height: Device.margin(context) * 2),
                    _signUpForm(),
                    Divider(color: Theme.of(context).colorScheme.surfaceVariant, height: Device.margin(context) * 4),
                    const Text('Already have an account?'),
                    SizedBox(height: Device.margin(context)),
                    ElevatedButton(
                        onPressed: () {
                          Get.toNamed(AppRouter.authLoginPageRoute);
                        },
                        child: const Text('SIGN IN'))
                  ],
                ),
              )),
        ),
      ),
      bottomNavigationBar: const MTerminalBottomAppBar(),
    );
  }

  Widget _signUpForm() {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(listener: (context, state) {
      if (state is SignedUpState) {
        Analytics.logSignUp();
        _fbKeySignUp.currentState!.reset();
        Get.toNamed(AppRouter.authSignupSuccessPageRoute);
      }
      if (state is SigningUpErrorState) {
        GetMterminal.snackBar(context, content: state.message);
      }
    }, builder: (context, state) {
      return FormBuilder(
        key: _fbKeySignUp,
        initialValue: {Keys.email: widget.email},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormBuilderTextField(
              name: Keys.firstName,
              decoration: const InputDecoration(label: Text('FIRST NAME')),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSubmitted: (value) {
                _validateEmailStage();
              },
            ),
            SizedBox(height: Device.margin(context)),
            FormBuilderTextField(
              name: Keys.lastName,
              decoration: const InputDecoration(label: Text('LAST NAME')),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSubmitted: (value) {
                _validateEmailStage();
              },
            ),
            SizedBox(height: Device.margin(context)),
            FormBuilderTextField(
              name: Keys.email,
              decoration: const InputDecoration(label: Text('EMAIL')),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Email is required to create your account.'),
                FormBuilderValidators.email(errorText: 'Please enter a valid email address.'),
              ]),
              readOnly: widget.email != null,
              onSubmitted: (value) {
                _validateEmailStage();
              },
            ),
            if (_currentStep == SignUpStep.password) ...[
              FadeIn(
                animate: true,
                child: Padding(
                  padding: EdgeInsets.only(top: Device.margin(context)),
                  child: FormBuilderTextField(
                    name: Keys.password,
                    obscureText: _obscurePassword,
                    obscuringCharacter: '*',
                    onChanged: (value) {
                      passNotifier.value = PasswordStrength.calculate(text: value ?? '');
                    },
                    decoration: InputDecoration(
                        label: const Text('PASSWORD'),
                        helperText: 'This password encrypts your data. If you forget it, you might lose your data.',
                        suffixIcon: ObscureVisibilityIcon(
                          isObscure: _obscurePassword,
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        )),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Please enter a secure password to create your account.'),
                    ]),
                  ),
                ),
              ),
              SizedBox(height: Device.margin(context)),
              PasswordStrengthChecker(
                strength: passNotifier,
                configuration: PasswordStrengthCheckerConfiguration(
                  borderWidth: 1.0,
                  borderColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              )
            ],
            SizedBox(height: Device.margin(context)),
            ButtonLoader(
              isLoading: state is SigningUpState,
              width: double.infinity,
              child: FilledButton(
                  style: state is SigningUpState ? WidgetHelper.buttonStyleWhenLoading : null,
                  onPressed: state is SigningUpState
                      ? null
                      : () {
                          if (_currentStep == SignUpStep.email) {
                            _validateEmailStage();
                          } else if (_currentStep == SignUpStep.password) {
                            _trySignUp();
                          }
                        },
                  child: const Text('CONTINUE')),
            ),
            Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: Device.margin(context) * 2, horizontal: Device.column(context)),
              child: RichText(
                text: TextSpan(text: 'By signing up, you agree to the mTerminal\n', style: Theme.of(context).textTheme.labelLarge, children: [
                  TextSpan(text: 'Term of Use', style: const TextStyle(color: kPrimaryLight), recognizer: _termsOfUseOnTapRecognizer),
                  const TextSpan(text: ' and '),
                  TextSpan(text: 'Privacy Policy', style: const TextStyle(color: kPrimaryLight), recognizer: _privacyPolicyOnTapRecognizer),
                ]),
                textAlign: TextAlign.center,
              ),
            ))
          ],
        ),
      );
    });
  }

  void _validateEmailStage() {
    if (_fbKeySignUp.currentState!.saveAndValidate()) {
      setState(() {
        _currentStep = SignUpStep.password;
      });
    }
  }

  void _trySignUp() {
    if (_fbKeySignUp.currentState!.saveAndValidate()) {
      final values = _fbKeySignUp.currentState!.value;
      BlocProvider.of<AuthenticationBloc>(context).add(SignUpEvent(data: values));
    }
  }

  void _openTermsOfUse() {
    Helper.openUrl(
      url: '${Endpoint.website}/terms-of-use',
    );
  }

  void _openPrivacyPolicy() {
    Helper.openUrl(
      url: '${Endpoint.website}/privacy-policy',
    );
  }
}
