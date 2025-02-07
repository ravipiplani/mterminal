import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../reactive/blocs/user/user_bloc.dart';
import '../../utilities/get_mterminal.dart';
import '../../widgets/obscure_visibility_icon.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key, required this.onSuccess, required this.email});

  final String email;
  final VoidCallback onSuccess;

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  late bool _obscurePassword;
  final _changeEmailKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    _obscurePassword = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Email'),
        centerTitle: false,
        actions: [const Icon(Icons.email), SizedBox(width: Device.margin(context))],
      ),
      body: Container(
        padding: EdgeInsets.all(Device.margin(context)),
        child: FormBuilder(
          key: _changeEmailKey,
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(widget.email)
                ),
              ),
              SizedBox(height: Device.margin(context) * 2),
              FormBuilderTextField(
                name: Keys.email,
                decoration: const InputDecoration(
                  label: Text('NEW EMAIL'),
                ),
                validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.email()]),
              ),
              SizedBox(height: Device.margin(context)),
              FormBuilderTextField(
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
                validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              ),
            ],
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        BlocConsumer<UserBloc, UserState>(listener: (context, state) {
          if (state is EmailChangedState) {
            widget.onSuccess();
          }
          if (state is ChangingEmailErrorState) {
            GetMterminal.snackBar(context, content: state.message);
          }
        }, builder: (context, state) {
          return TextButton(
              onPressed: state is ChangingEmailState
                  ? null
                  : () {
                      if (_changeEmailKey.currentState!.saveAndValidate()) {
                        BlocProvider.of<UserBloc>(context).add(ChangeEmailEvent(userId: GetMterminal.user().id, data: _changeEmailKey.currentState!.value));
                      }
                    },
              child: const Text('UPDATE EMAIL'));
        })
      ],
    );
  }
}
