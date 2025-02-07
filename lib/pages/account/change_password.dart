import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../reactive/blocs/user/user_bloc.dart';
import '../../utilities/get_mterminal.dart';
import '../../widgets/obscure_visibility_icon.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late bool _obscureOldPassword;
  late bool _obscurePassword;
  late bool _obscurePassword2;
  final _changePasswordKey = GlobalKey<FormBuilderState>();
  final passNotifier = ValueNotifier<PasswordStrength?>(null);

  @override
  void initState() {
    _obscureOldPassword = true;
    _obscurePassword = true;
    _obscurePassword2 = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: false,
        actions: [const Icon(Icons.password), SizedBox(width: Device.margin(context))],
      ),
      body: Container(
        padding: EdgeInsets.all(Device.margin(context)),
        child: FormBuilder(
          key: _changePasswordKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: Keys.oldPassword,
                obscureText: _obscureOldPassword,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                    label: const Text('CURRENT PASSWORD'),
                    suffixIcon: ObscureVisibilityIcon(
                      isObscure: _obscureOldPassword,
                      onPressed: () {
                        setState(() {
                          _obscureOldPassword = !_obscureOldPassword;
                        });
                      },
                    )),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(12),
                  FormBuilderValidators.maxLength(18),
                ]),
              ),
              SizedBox(height: Device.margin(context)),
              FormBuilderTextField(
                name: Keys.password,
                obscureText: _obscurePassword,
                obscuringCharacter: '*',
                onChanged: (value) {
                  passNotifier.value = PasswordStrength.calculate(text: value ?? '');
                },
                decoration: InputDecoration(
                    label: const Text('NEW PASSWORD'),
                    suffixIcon: ObscureVisibilityIcon(
                      isObscure: _obscurePassword,
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )),
                validator:
                    FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.minLength(12), FormBuilderValidators.maxLength(18)]),
              ),
              SizedBox(height: Device.margin(context)),
              FormBuilderTextField(
                name: Keys.password2,
                obscureText: _obscurePassword2,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                    label: const Text('CONFIRM PASSWORD'),
                    suffixIcon: ObscureVisibilityIcon(
                      isObscure: _obscurePassword2,
                      onPressed: () {
                        setState(() {
                          _obscurePassword2 = !_obscurePassword2;
                        });
                      },
                    )),
                validator:
                    FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.minLength(12), FormBuilderValidators.maxLength(18)]),
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
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        BlocConsumer<UserBloc, UserState>(listener: (context, state) {
          if (state is PasswordChangedState) {
            widget.onSuccess();
          }
          if (state is ChangingPasswordErrorState) {
            GetMterminal.snackBar(context, content: state.message);
          }
        }, builder: (context, state) {
          return TextButton(
              onPressed: state is ChangingPasswordState
                  ? null
                  : () {
                      if (_changePasswordKey.currentState!.saveAndValidate()) {
                        BlocProvider.of<UserBloc>(context)
                            .add(ChangePasswordEvent(userId: GetMterminal.user().id, data: _changePasswordKey.currentState!.value));
                      }
                    },
              child: const Text('UPDATE PASSWORD'));
        })
      ],
    );
  }
}
