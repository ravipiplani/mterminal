import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

import '../../app_router.dart';
import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../reactive/blocs/authentication/authentication_bloc.dart';
import '../../utilities/get_mterminal.dart';
import '../../widgets/button_loader.dart';
import '../../widgets/logo.dart';
import '../../widgets/mterminal_bottom_app_bar.dart';
import '../../widgets/obscure_visibility_icon.dart';
import '../../widgets/widget_helper.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.uid, required this.token});

  final String uid;
  final String token;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _fbKey = GlobalKey<FormBuilderState>();
  late bool _obscurePassword;
  late bool _obscureConfirmPassword;
  final passNotifier = ValueNotifier<PasswordStrength?>(null);

  @override
  void initState() {
    _obscurePassword = true;
    _obscureConfirmPassword = true;
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
                  Text('Reset Account Password', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black)),
                  SizedBox(height: Device.margin(context) * 2),
                  _resetPasswordForm(),
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
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MTerminalBottomAppBar(),
    );
  }

  Widget _resetPasswordForm() {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(listener: (context, state) {
      if (state is PasswordResetState) {
        _fbKey.currentState!.reset();
        GetMterminal.snackBar(context, content: state.message, action: SnackBarAction(label: 'Login', onPressed: () {
          Get.offAllNamed(AppRouter.authLoginPageRoute);
        }));
      }
      if (state is ResettingPasswordErrorState) {
        GetMterminal.snackBar(context, content: state.message);
      }
    }, builder: (context, state) {
      return FormBuilder(
        key: _fbKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormBuilderTextField(
              name: Keys.password,
              obscureText: _obscurePassword,
              obscuringCharacter: '*',
              onChanged: (value) {
                passNotifier.value = PasswordStrength.calculate(text: value ?? '');
              },
              decoration: InputDecoration(
                  label: const Text('PASSWORD'),
                  helperText: 'Please enter new password for your account.',
                  suffixIcon: ObscureVisibilityIcon(
                    isObscure: _obscurePassword,
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Please enter new password for your account.'),
              ]),
            ),
            SizedBox(height: Device.margin(context)),
            FormBuilderTextField(
              name: Keys.confirmPassword,
              obscureText: _obscureConfirmPassword,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                  label: const Text('CONFIRM PASSWORD'),
                  helperText: 'Please confirm your password.',
                  suffixIcon: ObscureVisibilityIcon(
                    isObscure: _obscureConfirmPassword,
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  )),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Please confirm your password.'),
              ]),
            ),
            SizedBox(height: Device.margin(context)),
            PasswordStrengthChecker(
              strength: passNotifier,
              configuration: PasswordStrengthCheckerConfiguration(
                borderWidth: 1.0,
                borderColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            SizedBox(height: Device.margin(context) * 2),
            ButtonLoader(
              isLoading: state is ResettingPasswordState,
              width: double.infinity,
              child: FilledButton(
                  style: state is ResettingPasswordState ? WidgetHelper.buttonStyleWhenLoading : null,
                  onPressed: state is ResettingPasswordState
                      ? null
                      : () {
                          if (_fbKey.currentState!.saveAndValidate()) {
                            final values = _fbKey.currentState!.value;
                            if (values[Keys.password] != values[Keys.confirmPassword]) {
                              GetMterminal.snackBar(context, content: 'Password and Confirm Password are not same.');
                              return;
                            }
                            BlocProvider.of<AuthenticationBloc>(context)
                                .add(ResetPasswordEvent(uid: widget.uid, token: widget.token, password: values[Keys.password]));
                          }
                        },
                  child: const Text('CONTINUE')),
            ),
          ],
        ),
      );
    });
  }
}
