import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';

import '../../config/constants.dart';
import '../../config/keys.dart';
import '../../config/lottie_files.dart';
import '../../config/svgs.dart';
import '../../layout/device.dart';
import '../../models/credential.dart';
import '../../models/secure_share.dart';
import '../../models/user.dart';
import '../../reactive/blocs/credential/credential_bloc.dart';
import '../../reactive/blocs/secure_share/secure_share_bloc.dart';
import '../../reactive/providers/app_provider.dart';
import '../../services/credential_service.dart';
import '../../services/secure_share_service.dart';
import '../../utilities/crypto.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/helper.dart';
import '../../widgets/action_tile.dart';
import '../../widgets/button_loader.dart';
import '../../widgets/info_card.dart';
import '../../widgets/obscure_visibility_icon.dart';
import '../../widgets/title_card.dart';
import 'add_credential.dart';

class CredentialPage extends StatefulWidget {
  const CredentialPage({super.key});

  @override
  State<CredentialPage> createState() => _CredentialPageState();
}

class _CredentialPageState extends State<CredentialPage> {
  List<Credential> _credentials = [];
  final _credentialService = CredentialService();
  final _enableSecureShareFormKey = GlobalKey<FormBuilderState>();
  final _accessSecureShareFormKey = GlobalKey<FormBuilderState>();
  late AppProvider _watchAppProvider;
  late String _secureSharePassword;
  late int _secureShareExpiryMinutes;
  late User _user;

  @override
  void initState() {
    _getCredentials();
    if (context.read<AppProvider>().isLoggedIn) {
      BlocProvider.of<SecureShareBloc>(context).add(GetSecureSharesEvent());
    }
    _user = GetMterminal.user();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _watchAppProvider = context.watch<AppProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Device.margin(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_watchAppProvider.isLoggedIn && !GetMterminal.isLightCustomer) _manageCredentials,
            SizedBox(height: Device.margin(context)),
            BlocBuilder<CredentialBloc, CredentialState>(builder: (context, state) {
              if (state is RetrieveCredentialsState) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CredentialsRetrievedState) {
                _credentials = state.credentials;
              }
              if (_credentials.isEmpty) {
                return const Center(
                  child: InfoCard(svg: SVGS.secureFiles, description: 'Add your server access keys here.'),
                );
              }
              return SingleChildScrollView(
                child: Wrap(
                  children: _credentials
                      .map((credential) => Container(
                            width: 360,
                            margin: EdgeInsets.only(right: Device.margin(context), bottom: Device.margin(context)),
                            child: ActionTile(
                                title: credential.name,
                                subTitle: credential.type == CredentialType.pemKey ? 'RSA' : 'USERNAME/PASSWORD',
                                leading: CircleAvatar(child: Text(credential.name[0].toUpperCase())),
                                trailingIcon: Icons.edit,
                                onTap: () {
                                  showModalSideSheet(
                                      context: context,
                                      withCloseControll: false,
                                      width: Device.isMobile(context) ? Device.width(context) : null,
                                      barrierDismissible: true,
                                      body: AddCredential(
                                        credential: credential,
                                        callback: _getCredentials,
                                      ));
                                }),
                          ))
                      .toList(),
                ),
              );
            }),
            Padding(padding: EdgeInsets.only(bottom: Device.margin(context) * 4))
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalSideSheet(
              context: context,
              withCloseControll: false,
              width: Device.isMobile(context) ? Device.width(context) : null,
              barrierDismissible: true,
              body: AddCredential(callback: _getCredentials));
        },
        label: const Text('Add Credential'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _getCredentials() {
    BlocProvider.of<CredentialBloc>(context).add(GetCredentialsEvent());
  }

  Widget get _manageCredentials {
    return BlocBuilder<SecureShareBloc, SecureShareState>(builder: (context, state) {
      if (state is SecureSharesRetrievedState) {
        return TitleCard(
            title: 'Share Credentials',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                      text:
                          'As a security measure, your credentials are saved on your device and are never sent to our servers.\nIf you wish to share it with your team, you can ',
                      children: [
                        TextSpan(
                            mouseCursor: SystemMouseCursors.click,
                            text: 'Secure Share',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        const TextSpan(text: ' or Export/Import credentials.'),
                      ],
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
                SizedBox(height: Device.margin(context)),
                if (state.secureShares.isEmpty) ...[
                  FilledButton.icon(onPressed: _enableSecureShare, icon: const Icon(Icons.security), label: const Text('Secure Share')),
                  SizedBox(height: Device.margin(context) / 2),
                  Text(
                    'Encrypted time-bound sharing',
                    style: Theme.of(context).textTheme.labelMedium,
                  )
                ] else
                  SizedBox(
                    width: Device.isDesktop(context) ? 500 : null,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.security),
                      title: Row(
                        children: [
                          const Text('Secure Share Enabled'),
                          if (state.secureShares.first.createdBy == _user.id)
                            TextButton(
                                onPressed: () {
                                  _disableSecureShare(state.secureShares.first);
                                },
                                child: const Text('Disable'))
                        ],
                      ),
                      subtitle: Text('Will expire by ${DateFormat(Keys.ddMMMMyHmsa).format(state.secureShares.first.expiryAt.toLocal())}'),
                      trailing: FilledButton(
                          onPressed: () {
                            _accessSecureShare(state.secureShares.first);
                          },
                          child: const Text('Get Credentials')),
                    ),
                  ),
                SizedBox(height: Device.margin(context)),
                Row(
                  children: [
                    TextButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: [kAppName.toLowerCase()]);
                          if (result != null) {
                            final file = File(result.files.single.path!);
                            final content = await file.readAsString();
                            final credentials = jsonDecode(content);
                            for (final credential in credentials) {
                              final data = jsonDecode(credential);
                              data.remove('id');
                              await _credentialService.insert(details: data);
                            }
                            _getCredentials();
                            if (context.mounted) GetMterminal.snackBar(context, content: 'Imported successfully.');
                          }
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text('Import Credentials')),
                    const Spacer(),
                    FilledButton.tonal(
                        onPressed: () {
                          GetMterminal.exportCredentials().then((value) {
                            if (value) {
                              GetMterminal.snackBar(context, content: 'Exported successfully.');
                            } else {
                              GetMterminal.snackBar(context, content: 'Exported failed.');
                            }
                          }).catchError((err) {
                            GetMterminal.snackBar(context, content: 'Exported failed. ${err.toString()}');
                          });
                        },
                        child: const Text('Export')),
                  ],
                ),
              ],
            ));
      }
      return Container();
    });
  }

  void _enableSecureShare() {
    showDialog(
        context: context,
        builder: (context) {
          bool obscurePassword = true;
          return StatefulBuilder(builder: (context, setDialogState) {
            return BlocBuilder<SecureShareBloc, SecureShareState>(builder: (context, state) {
              return AlertDialog(
                icon: const Icon(Icons.security),
                title: const Text('Secure Share your Credentials'),
                content: SizedBox(
                  width: Device.isDesktop(context) ? Device.grid(context) * 4 : null,
                  child: state is SecureShareCreatedState
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LottieBuilder.asset(LottieFiles.success, width: 200, repeat: false),
                            Text(
                                'Secure share created successfully for $_secureShareExpiryMinutes minutes. Please copy the provided password and share it with your team.'),
                            ActionChip(
                              label: Text(_secureSharePassword),
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: _secureSharePassword));
                              },
                              avatar: const Icon(Icons.copy),
                            )
                          ],
                        )
                      : FormBuilder(
                          key: _enableSecureShareFormKey,
                          initialValue: {Keys.isSingleUse: false, Keys.password: Helper.generateSecurePassword()},
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Securely share your credentials using the below settings.'),
                              SizedBox(height: Device.margin(context)),
                              FormBuilderDropdown(
                                  name: Keys.expiryDuration,
                                  decoration: const InputDecoration(
                                      label: Text('Expiry Time'), helperText: 'Credential sharing will be disabled after the specified time.'),
                                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                                  items: const [
                                    DropdownMenuItem(value: 5, child: Text('5 Minutes')),
                                    DropdownMenuItem(value: 10, child: Text('10 Minutes')),
                                    DropdownMenuItem(value: 30, child: Text('30 Minutes')),
                                  ]),
                              SizedBox(height: Device.margin(context)),
                              FormBuilderTextField(
                                  name: Keys.password,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.minLength(8),
                                    FormBuilderValidators.maxLength(16),
                                  ]),
                                  obscureText: obscurePassword,
                                  obscuringCharacter: '*',
                                  decoration: InputDecoration(
                                      label: const Text('Encryption Password'),
                                      helperText: 'Specify a password for encryption. Without this, your cannot access the credentials.',
                                      suffixIcon: ObscureVisibilityIcon(
                                        isObscure: obscurePassword,
                                        onPressed: () {
                                          setDialogState(() {
                                            obscurePassword = !obscurePassword;
                                          });
                                        },
                                      ))),
                              SizedBox(height: Device.margin(context)),
                              FormBuilderSwitch(
                                name: Keys.isSingleUse,
                                title: const Text('Can be accessed only once?'),
                                subtitle: const Text('If turned on, sharing will be disabled after 1 successful access.'),
                              )
                            ],
                          ),
                        ),
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  if (state is SecureShareCreatedState)
                    FilledButton(
                        onPressed: () {
                          Get.back();
                          BlocProvider.of<SecureShareBloc>(context).add(GetSecureSharesEvent());
                        },
                        child: const Text('Close'))
                  else
                    ButtonLoader(
                      isLoading: state is CreatingSecureShareState,
                      child: FilledButton(
                          onPressed: state is CreatingSecureShareState
                              ? null
                              : () {
                                  if (_enableSecureShareFormKey.currentState!.saveAndValidate()) {
                                    final formValue = _enableSecureShareFormKey.currentState!.value;

                                    _secureSharePassword = formValue[Keys.password];
                                    _secureShareExpiryMinutes = formValue[Keys.expiryDuration];

                                    final key = _secureSharePassword.padLeft(16, 'X');
                                    final iv = IV.fromSecureRandom(16);
                                    final data = {
                                      Keys.isSingleUse: formValue[Keys.isSingleUse],
                                      Keys.expiryAt: DateTime.now().add(Duration(minutes: _secureShareExpiryMinutes)).toIso8601String(),
                                      Keys.iv: iv.base64,
                                      Keys.accesses: []
                                    };

                                    final credentials = [];
                                    for (final credential in _credentials) {
                                      credentials.add(credential.toJson());
                                    }
                                    final credentialsData = jsonEncode(credentials);
                                    final crypto = Crypto(key: key, iv: iv);
                                    final encryptedData = crypto.encrypt(credentialsData);
                                    data.addAll({Keys.data: encryptedData});
                                    BlocProvider.of<SecureShareBloc>(context).add(CreateSecureShareEvent(data: data));
                                  }
                                },
                          child: const Text('Secure Share')),
                    )
                ],
              );
            });
          });
        });
  }

  void _accessSecureShare(SecureShare secureShare) {
    showDialog(
        context: context,
        builder: (context) {
          bool obscurePassword = true;
          bool readyToImport = false;
          String? errorMessage;
          List<String> duplicateCredentials = [];
          List decryptedCredentials = [];
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              icon: const Icon(Icons.security),
              title: const Text('Access Credentials via Secure Share'),
              content: SizedBox(
                  width: Device.isDesktop(context) ? Device.grid(context) * 4 : null,
                  child: FormBuilder(
                    key: _accessSecureShareFormKey,
                    initialValue: const {Keys.isSingleUse: false},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enter the password provided by your team.'),
                        SizedBox(height: Device.margin(context)),
                        FormBuilderTextField(
                            name: Keys.password,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(8),
                              FormBuilderValidators.maxLength(16),
                            ]),
                            obscureText: obscurePassword,
                            obscuringCharacter: '*',
                            decoration: InputDecoration(
                                label: const Text('Encryption Password'),
                                suffixIcon: ObscureVisibilityIcon(
                                  isObscure: obscurePassword,
                                  onPressed: () {
                                    setDialogState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ))),
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.error),
                          ),
                        if (duplicateCredentials.isNotEmpty) ...[
                          SizedBox(height: Device.margin(context)),
                          Text('Duplicate keys will not be imported.\nDuplicate keys: ${duplicateCredentials.join(', ')}')
                        ]
                      ],
                    ),
                  )),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                if (readyToImport)
                  FilledButton.tonal(
                      onPressed: () {
                        setDialogState(() {
                          readyToImport = false;
                          duplicateCredentials = [];
                        });
                        _accessSecureShareFormKey.currentState!.reset();
                      },
                      child: const Text('Cancel')),
                FilledButton(
                    onPressed: () async {
                      if (readyToImport) {
                        for (final credential in decryptedCredentials) {
                          if (duplicateCredentials.contains(credential[Keys.name])) {
                            continue;
                          }
                          await _credentialService.insert(details: {
                            Keys.type: credential[Keys.type],
                            Keys.name: credential[Keys.name],
                            Keys.password: credential[Keys.password],
                            Keys.privateKey: credential[Keys.privateKey],
                          });
                        }
                        final accesses = List<int>.from(secureShare.accesses);
                        accesses.add(_user.id);
                        await SecureShareService().update(secureShareId: secureShare.id, data: {Keys.accesses: accesses});
                        if (secureShare.isSingleUse) {
                          await SecureShareService().delete(secureShareId: secureShare.id);
                        }
                        if (context.mounted) GetMterminal.snackBar(context, content: 'Credentials imported successfully.');
                        _getCredentials();
                        if (context.mounted) BlocProvider.of<SecureShareBloc>(context).add(GetSecureSharesEvent());
                        Get.back();
                      } else if (_accessSecureShareFormKey.currentState!.saveAndValidate()) {
                        final formValue = _accessSecureShareFormKey.currentState!.value;

                        _secureSharePassword = formValue[Keys.password];

                        final key = _secureSharePassword.padLeft(16, 'X');
                        final iv = IV.fromBase64(secureShare.iv);

                        final crypto = Crypto(key: key, iv: iv);
                        try {
                          final decryptedData = crypto.decrypt(secureShare.data);
                          decryptedCredentials = jsonDecode(decryptedData) as List;
                          for (final credential in decryptedCredentials) {
                            if (_credentials.where((element) => element.name == credential[Keys.name]).isNotEmpty) {
                              duplicateCredentials.add(credential[Keys.name]);
                            }
                          }
                          setDialogState(() {
                            errorMessage = null;
                            duplicateCredentials = List<String>.from(duplicateCredentials);
                            readyToImport = true;
                          });
                        } on ArgumentError {
                          setDialogState(() {
                            errorMessage = 'Given password is not valid. Please enter the correct password.';
                            duplicateCredentials = [];
                            readyToImport = false;
                          });
                        }
                      }
                    },
                    child: Text(readyToImport ? 'Import Credentials' : 'Access Secure Share'))
              ],
            );
          });
        });
  }

  void _disableSecureShare(SecureShare secureShare) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              icon: const Icon(Icons.security),
              title: const Text('Disable Secure Share'),
              content: const Text('Are you sure you want to disable secure share?'),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Go Back')),
                FilledButton(
                    onPressed: () async {
                      await SecureShareService().delete(secureShareId: secureShare.id);
                      if (context.mounted) {
                        GetMterminal.snackBar(context, content: 'Secure share disabled successfully.');
                        BlocProvider.of<SecureShareBloc>(context).add(GetSecureSharesEvent());
                      }
                      Get.back();
                    },
                    child: const Text('Disable'))
              ],
            );
          });
        });
  }
}
