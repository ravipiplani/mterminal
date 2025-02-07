import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';

import '../../app_router.dart';
import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../models/user.dart';
import '../../reactive/blocs/app_device/app_device_bloc.dart';
import '../../reactive/blocs/authentication/authentication_bloc.dart';
import '../../reactive/blocs/payment/payment_bloc.dart';
import '../../reactive/blocs/user/user_bloc.dart';
import '../../reactive/providers/app_provider.dart';
import '../../services/user_service.dart';
import '../../utilities/app_store.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/helper.dart';
import '../../widgets/button_loader.dart';
import '../../widgets/installers.dart';
import '../../widgets/obscure_visibility_icon.dart';
import '../../widgets/plan_upgrade_card.dart';
import '../../widgets/title_card.dart';
import 'change_email.dart';
import 'change_password.dart';

enum DeleteAccountState { started, confirmed, deleteInitiated }

enum RestoreStatus { undefined, processing, failed, success, nothingToRestore }

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? _user;
  late AppProvider _watchAppProvider;
  late Future<User> _futureUser;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final _restoreStatus = ValueNotifier<RestoreStatus>(RestoreStatus.undefined);
  bool _removeCredentials = false;

  @override
  void initState() {
    try {
      _user = GetMterminal.user();
      BlocProvider.of<AppDeviceBloc>(context).add(GetAppDevicesEvent());
    } on Exception {
      _user = null;
    }
    _futureUser = UserService().me();
    if (AppStore.isAppleDevice) {
      _initializeInAppPurchase();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (AppStore.isAppleDevice) {
      _subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _watchAppProvider = context.watch<AppProvider>();
    if (!_watchAppProvider.isLoggedIn) {
      return Center(
        child: FilledButton(
          onPressed: () {
            Get.toNamed(AppRouter.authLoginPageRoute);
          },
          child: const Text('Get Started'),
        ),
      );
    }
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(Device.margin(context)),
        child: Column(
          children: [
            _licenseView,
            SizedBox(height: Device.margin(context)),
            FutureBuilder<User>(
                future: _futureUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    _user = snapshot.data!;
                    return _accountView;
                  }
                  return const SizedBox();
                }),
            if (kIsWeb) ...[
              SizedBox(height: Device.margin(context)),
              const Installers(),
            ],
            _deleteAccountView
          ],
        ),
      ),
    );
  }

  Widget get _licenseView {
    return TitleCard(
      title: '${_user!.firstName} ${_user!.lastName}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (AppStore.isAppleDevice)
                TextButton(
                    onPressed: () async {
                      BlocProvider.of<PaymentBloc>(context).add(UninitializedPaymentEvent());
                      _restoreStatus.value = RestoreStatus.processing;
                      AppStore.inAppPurchase.restorePurchases(applicationUserName: GetMterminal.user().uuid);
                      _restoreLicenseDialog();
                    },
                    child: const Text('Restore License')),
              const Spacer(),
              BlocConsumer<AuthenticationBloc, AuthenticationState>(listener: (context, state) async {
                if (state is LoggedOutState) {
                  await Helper.logOut(removeCredentials: _removeCredentials);
                  if (context.mounted) context.read<AppProvider>().selectedNavigationRailIndex = 0;
                  Get.offAllNamed(AppRouter.homePageRoute);
                }
              }, builder: (context, state) {
                return ButtonLoader(
                  isLoading: state is LoggingOutState,
                  width: Device.column(context) * 2,
                  child: Device.isDesktop(context)
                      ? FilledButton.tonal(onPressed: state is LoggingOutState ? null : _logOut, child: const Text('Log Out'))
                      : IconButton.filledTonal(onPressed: state is LoggingOutState ? null : _logOut, icon: const Icon(Icons.logout)),
                );
              })
            ],
          )
        ],
      ),
    );
  }

  Widget get _accountView {
    return TitleCard(
        title: 'Account',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text(_user!.email.substring(0, 1).toUpperCase())),
              title: Text(_user!.email),
              subtitle: _user!.isEmailVerified
                  ? null
                  : const Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text('Unverified'),
                      ),
                    ),
              isThreeLine: !_user!.isEmailVerified,
              trailing: Device.isDesktop(context)
                  ? FilledButton.tonal(onPressed: _changeEmail, child: const Text('Change'))
                  : IconButton.filledTonal(
                      onPressed: _changeEmail,
                      icon: const Icon(Icons.change_circle),
                      tooltip: 'Change Email',
                    ),
            ),
            Row(
              children: [
                TextButton(onPressed: _changePassword, child: const Text('Change Password')),
                if (!_user!.isEmailVerified)
                  BlocConsumer<UserBloc, UserState>(listener: (context, state) {
                    if (state is EmailVerificationLinkResentState) {
                      GetMterminal.snackBar(context, content: 'Email verification link sent to ${_user!.email}');
                    } else if (state is ResendingEmailVerificationLinkErrorState) {
                      GetMterminal.snackBar(context, content: state.message);
                    }
                  }, builder: (context, state) {
                    return TextButton(
                        onPressed: state is ResendingEmailVerificationLinkState
                            ? null
                            : () {
                                BlocProvider.of<UserBloc>(context).add(ResendEmailVerificationLinkEvent(userId: _user!.id));
                              },
                        child: const Text('Resend Verification Link'));
                  }),
              ],
            )
          ],
        ));
  }

  Widget get _deleteAccountView {
    bool confirmAccountDelete = false;
    DeleteAccountState currentState = DeleteAccountState.started;
    String? password;
    final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    bool obscurePassword = true;
    return Container(
      padding: EdgeInsets.all(Device.margin(context)),
      child: TextButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (dialogContext) {
                return StatefulBuilder(builder: (dialogContext, setDialogState) {
                  return ScaffoldMessenger(
                    key: scaffoldMessengerKey,
                    child: Scaffold(
                      body: AlertDialog(
                        icon: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                        title: const Text('Are you sure you want to delete your account?'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'This will result in following irreversible actions:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Padding(
                              padding: EdgeInsets.all(Device.margin(context)),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('All the hosts connection details added by you will be permanently deleted.'),
                                  Text('All the users added by you will be permanently deleted.'),
                                  Text('All the teams created by you will be permanently deleted.'),
                                  Text('All the account details - including your email and contact details will be permanently removed from the system.')
                                ],
                              ),
                            ),
                            TextFormField(
                              onChanged: (value) {
                                final confirmed = value.toLowerCase() == 'delete account';
                                setDialogState(() {
                                  confirmAccountDelete = confirmed;
                                });
                              },
                              decoration: const InputDecoration(labelText: "Type 'Delete Account' to confirm"),
                            ),
                            if (currentState == DeleteAccountState.confirmed) ...[
                              SizedBox(height: Device.margin(context)),
                              FormBuilderTextField(
                                name: Keys.password,
                                obscureText: obscurePassword,
                                obscuringCharacter: '*',
                                decoration: InputDecoration(
                                    label: const Text('Password'),
                                    helperText: 'Please enter your account password to proceed.',
                                    suffixIcon: ObscureVisibilityIcon(
                                      isObscure: obscurePassword,
                                      onPressed: () {
                                        setDialogState(() {
                                          obscurePassword = !obscurePassword;
                                        });
                                      },
                                    )),
                                onChanged: (value) {
                                  password = value;
                                },
                              )
                            ],
                          ],
                        ),
                        actions: [
                          FilledButton(onPressed: Get.back, child: const Text('NO, I WANT TO KEEP IT')),
                          if (currentState == DeleteAccountState.started)
                            FilledButton(
                              onPressed: confirmAccountDelete
                                  ? () {
                                      setDialogState(() {
                                        currentState = DeleteAccountState.confirmed;
                                      });
                                    }
                                  : null,
                              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                              child: const Text('CONTINUE TO DELETE'),
                            ),
                          if (currentState == DeleteAccountState.confirmed)
                            BlocConsumer<UserBloc, UserState>(listener: (context, state) {
                              if (state is AccountDeletedState) {
                                GetMterminal.snackBar(context, content: state.message, state: scaffoldMessengerKey.currentState);
                                Future.delayed(const Duration(seconds: 1)).then((value) {
                                  _logOut();
                                });
                              }
                              if (state is DeletingAccountErrorState) {
                                GetMterminal.snackBar(context, content: state.message, state: scaffoldMessengerKey.currentState);
                              }
                            }, builder: (context, state) {
                              return FilledButton(
                                onPressed: state is DeletingAccountState
                                    ? null
                                    : () {
                                        if (password != null && password!.isNotEmpty) {
                                          BlocProvider.of<UserBloc>(context).add(DeleteAccountEvent(password: password!));
                                        }
                                      },
                                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                                child: Text(state is DeletingAccountState ? 'DELETING ACCOUNT...' : 'UMM! DELETE MY ACCOUNT'),
                              );
                            }),
                        ],
                      ),
                    ),
                  );
                });
              });
        },
        child: Text('DELETE ACCOUNT', style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
    );
  }

  void _logOut() {
    if (kIsWeb) {
      BlocProvider.of<AuthenticationBloc>(context).add(LogOutEvent());
    } else {
      showDialog(
          context: context,
          builder: (context) {
            var isAcknowledged = false;
            return StatefulBuilder(builder: (context, setLogOutDialogState) {
              return AlertDialog(
                icon: const Icon(Icons.logout),
                title: const Text('Confirm logging out?'),
                content: SizedBox(
                  width: Device.isDesktop(context) ? Device.column(context) * 6 : Device.width(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderCheckbox(
                        name: 'remove_credentials',
                        title: const Text('Remove locally stored credentials'),
                        subtitle: const Text("We do not store host access keys on mTerminal servers."),
                        onChanged: (value) {
                          setLogOutDialogState(() {
                            _removeCredentials = value ?? false;
                          });
                        },
                      ),
                      if (_removeCredentials)
                        FormBuilderCheckbox(
                          name: 'i_acknowledge',
                          title: const Text('I acknowledge that I have taken the backup of the credentials.'),
                          subtitle: const Text("You will lose access to the credentials if you have not exported them."),
                          onChanged: (value) {
                            setLogOutDialogState(() {
                              isAcknowledged = value ?? false;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
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
                      child: const Text('Export Credentials')),
                  FilledButton(
                      onPressed: _removeCredentials && !isAcknowledged
                          ? null
                          : () {
                              BlocProvider.of<AuthenticationBloc>(context).add(LogOutEvent());
                              Get.back();
                            },
                      child: const Text('Log Out'))
                ],
              );
            });
          });
    }
  }

  void _changePassword() {
    showModalSideSheet(
        context: context,
        width: Device.isMobile(context) ? Device.width(context) : null,
        withCloseControll: false,
        body: ChangePassword(onSuccess: _onPasswordChanged));
  }

  void _onPasswordChanged() async {
    GetMterminal.snackBar(context, content: 'Password changed successfully. Please login again.');
    BlocProvider.of<AuthenticationBloc>(context).add(LogOutEvent());
  }

  void _changeEmail() {
    showModalSideSheet(
        context: context,
        width: Device.isMobile(context) ? Device.width(context) : null,
        withCloseControll: false,
        body: ChangeEmail(email: GetMterminal.user().email, onSuccess: _onEmailChanged));
  }

  void _onEmailChanged() async {
    GetMterminal.snackBar(context, content: 'Email changed successfully. Please login again.');
    BlocProvider.of<AuthenticationBloc>(context).add(LogOutEvent());
  }

  void _restoreLicenseDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ValueListenableBuilder<RestoreStatus>(
              valueListenable: _restoreStatus,
              builder: (_, restoreStatus, __) {
                return BlocBuilder<PaymentBloc, PaymentState>(builder: (context, state) {
                  final isLoading = state is RestoringPurchaseState || restoreStatus == RestoreStatus.processing;
                  var title = 'Restoring license...';
                  var body = '';
                  if (state is PurchaseRestoredState) {
                    title = 'License Restored';
                    body = '';
                  } else if (state is RestoringPurchaseErrorState) {
                    title = 'Restore Failed';
                    body = state.message;
                  } else if (restoreStatus == RestoreStatus.nothingToRestore) {
                    title = 'Nothing to restore';
                    body = 'Click on upgrade button to buy a new license.';
                  }
                  return AlertDialog(
                    icon: const Icon(Icons.restore),
                    title: Text(title),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [if (isLoading) const CircularProgressIndicator() else Text(body)],
                    ),
                    actions: [
                      if (restoreStatus == RestoreStatus.nothingToRestore || state is RestoringPurchaseErrorState)
                        TextButton(
                            onPressed: () {
                              upgradePlan(context);
                            },
                            child: const Text('Upgrade')),
                      if (!isLoading)
                        TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text('Go Back'))
                    ],
                  );
                });
              });
        });
  }

  void _initializeInAppPurchase() {
    final Stream<List<PurchaseDetails>> purchaseStream = AppStore.inAppPurchase.purchaseStream;
    _subscription = purchaseStream.listen((purchaseDetails) {
      if (purchaseDetails.isEmpty) {
        _restoreStatus.value = RestoreStatus.nothingToRestore;
      }
      AppStore.handlePurchases(
          purchaseDetails: purchaseDetails,
          onSuccess: (purchaseDetail) {
            _restoreStatus.value = RestoreStatus.success;
            BlocProvider.of<PaymentBloc>(context).add(RestorePurchaseEvent(
                productId: purchaseDetail.productID,
                purchaseId: purchaseDetail.purchaseID!,
                signature: purchaseDetail.verificationData.serverVerificationData));
          },
          onFailure: () {
            _restoreStatus.value = RestoreStatus.failed;
          });
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _subscription.resume();
    });
  }
}
