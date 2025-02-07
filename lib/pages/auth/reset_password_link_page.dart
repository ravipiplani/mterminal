import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../app_router.dart';
import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../reactive/blocs/authentication/authentication_bloc.dart';
import '../../utilities/get_mterminal.dart';
import '../../widgets/button_loader.dart';
import '../../widgets/logo.dart';
import '../../widgets/mterminal_bottom_app_bar.dart';
import '../../widgets/widget_helper.dart';

class ResetPasswordLinkPage extends StatefulWidget {
  const ResetPasswordLinkPage({super.key});

  @override
  State<ResetPasswordLinkPage> createState() => _ResetPasswordLinkPageState();
}

class _ResetPasswordLinkPageState extends State<ResetPasswordLinkPage> {
  final _fbKey = GlobalKey<FormBuilderState>();

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
                  _resetPasswordLinkForm(),
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

  Widget _resetPasswordLinkForm() {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(listener: (context, state) {
      if (state is ResetPasswordLinkSentState) {
        _fbKey.currentState!.reset();
        GetMterminal.snackBar(context, content: state.message);
      }
      if (state is SendingResetPasswordLinkErrorState) {
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
              name: Keys.email,
              decoration: const InputDecoration(label: Text('EMAIL')),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
            ),
            SizedBox(height: Device.margin(context) * 2),
            ButtonLoader(
              isLoading: state is SendingResetPasswordLinkState,
              width: double.infinity,
              child: FilledButton(
                  style: state is SendingResetPasswordLinkState ? WidgetHelper.buttonStyleWhenLoading : null,
                  onPressed: state is SendingResetPasswordLinkState
                      ? null
                      : () {
                          if (_fbKey.currentState!.saveAndValidate()) {
                            BlocProvider.of<AuthenticationBloc>(context).add(SendResetPasswordLinkEvent(email: _fbKey.currentState!.value[Keys.email]));
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
