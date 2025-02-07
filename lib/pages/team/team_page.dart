import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';

import '../../app_router.dart';
import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../models/app_device.dart';
import '../../models/license.dart';
import '../../models/role_type.dart';
import '../../models/team_invite.dart';
import '../../models/team_user.dart';
import '../../reactive/blocs/app_device/app_device_bloc.dart';
import '../../reactive/blocs/team/team_bloc.dart';
import '../../services/user_service.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/mterminal_sync.dart';
import '../../widgets/dialogs/team_change_dialog.dart';
import '../../widgets/plan_upgrade_card.dart';
import '../../widgets/pricing_card.dart';
import '../../widgets/title_card.dart';
import 'invite_user.dart';
import 'update_team.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final _selectedTeam = GetMterminal.selectedTeam();
  late bool _canDeleteAdminUser;
  final _cancelInviteTeamBloc = TeamBloc();
  late License _license;

  @override
  void initState() {
    BlocProvider.of<TeamBloc>(context).add(GetTeamEvent(teamId: _selectedTeam.id));
    BlocProvider.of<AppDeviceBloc>(context).add(GetAppDevicesEvent());
    _license = GetMterminal.activeLicense();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _body;
  }

  Widget get _body {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Device.margin(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _teamHeaderView,
              SizedBox(height: Device.margin(context)),
              _currentPlanView,
              SizedBox(height: Device.margin(context)),
              _teamMemberView,
              SizedBox(height: Device.margin(context)),
              _teamInviteView,
              SizedBox(height: Device.margin(context)),
              _devicesView,
              if (!kIsWeb && _license.subscriptionPlan.costPerMonth != 0) ...[SizedBox(height: Device.margin(context)), _syncCardView]
            ],
          ),
        ),
      ),
    );
  }

  Widget get _teamHeaderView => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ActionChip(
            label: Row(
              children: [
                const Icon(
                  Icons.edit,
                  size: 12,
                ),
                SizedBox(width: Device.margin(context)),
                Text(_selectedTeam.name)
              ],
            ),
            onPressed: () {
              showModalSideSheet(
                  context: context,
                  width: Device.isMobile(context) ? Device.width(context) : null,
                  barrierDismissible: true,
                  withCloseControll: false,
                  body: UpdateTeam(
                    team: _selectedTeam,
                    onSuccess: () {
                      Get.offAllNamed(AppRouter.homePageRoute, parameters: {Keys.tab: Keys.settings});
                    },
                  ));
            },
          ),
          if (GetMterminal.user().teams.length > 1)
            IconButton(
              onPressed: () {
                showTeamChangeDialog(context);
              },
              icon: const Icon(Icons.change_circle_outlined),
              tooltip: 'Change Team',
            ),
          // const Spacer(),
          // TextButton.icon(
          //     onPressed: () {
          //       _createTeamDialog();
          //     },
          //     icon: const Icon(Icons.add),
          //     label: const Text('Create Team'))
        ],
      );

  Widget get _currentPlanView => TitleCard(
      title: 'Current Plan',
      child: Row(
        children: [
          ActionChip(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PricingCard(showPrice: false, subscriptionPlan: _license.subscriptionPlan),
                        Padding(
                          padding: EdgeInsets.only(bottom: Device.margin(context) * 2),
                          child: FilledButton(onPressed: Get.back, child: const Text('OK')),
                        )
                      ],
                    ));
                  });
            },
            label: Text(_license.subscriptionPlan.description),
          ),
          SizedBox(width: Device.margin(context)),
          if (GetMterminal.isLightCustomer)
            FilledButton(
                onPressed: () {
                  upgradePlan(context);
                },
                child: const Text('Upgrade'))
          else
            Expanded(
                child:
                    Text('Perpetual license. Updates available until ${DateFormat(Keys.ddMMMMy).format(_license.startDate.add(const Duration(days: 365)))}')),
        ],
      ));

  Widget get _teamMemberView => TitleCard(
      title: 'Team',
      actions: [
        TextButton.icon(
            onPressed: () {
              if (_license.areSeatsAvailable) {
                showModalSideSheet(
                    context: context,
                    width: Device.isMobile(context) ? Device.width(context) : null,
                    barrierDismissible: true,
                    withCloseControll: false,
                    body: InviteUser(
                      validate: (email) {},
                    ));
              } else {
                upgradePlan(context);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add User'))
      ],
      child: BlocConsumer<TeamBloc, TeamState>(
          listener: (context, state) {},
          builder: (context, state) {
            final teamUsers = <TeamUser>[];
            if (state is TeamRetrievedState) {
              teamUsers.addAll(state.team.teamUsers);
              final loggedInUser = teamUsers.firstWhere((teamUser) => teamUser.user.id == GetMterminal.user().id);
              _canDeleteAdminUser = loggedInUser.role == RoleType.admin && teamUsers.where((teamUser) => teamUser.role == RoleType.admin).length > 1;
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Chip(
                      label: Text('${_license.totalSeats} Total Seats'),
                    ),
                    SizedBox(width: Device.margin(context)),
                    Chip(
                      label: Text('${_license.occupiedSeats} Used Seats'),
                    ),
                    SizedBox(width: Device.margin(context)),
                    Chip(
                      label: Text('${_license.totalSeats - _license.occupiedSeats} Seats Available'),
                      labelStyle: TextStyle(color: _license.areSeatsAvailable ? Colors.green : Colors.red),
                    ),
                    SizedBox(width: Device.margin(context)),
                    ActionChip(
                      label: const Text('Add Seats'),
                      onPressed: () {
                        upgradePlan(context);
                      },
                      avatar: const Icon(Icons.add),
                    ),
                  ]),
                ),
                SizedBox(height: Device.margin(context)),
                ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(Device.margin(context)),
                    physics: const NeverScrollableScrollPhysics(),
                    children: teamUsers.map((teamUser) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("${teamUser.user.fullName.capitalize ?? 'Name'} (${teamUser.roleLabel})"),
                        subtitle: Text(teamUser.user.email),
                        // trailing: _canDeleteAdminUser ? IconButton(icon: const Icon(Icons.delete), onPressed: () {}) : null,
                      );
                    }).toList()),
              ],
            );
          }));

  Widget get _teamInviteView => BlocBuilder<TeamBloc, TeamState>(builder: (context, state) {
        final teamInvites = <TeamInvite>[];
        if (state is TeamRetrievedState) {
          if (state.team.teamInvites.isEmpty) {
            return const SizedBox();
          }
          teamInvites.addAll(state.team.teamInvites);
        }
        return TitleCard(
            title: 'Invited Users',
            child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(Device.margin(context)),
                children: teamInvites.map((teamInvite) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(teamInvite.user.email),
                    subtitle: Text(teamInvite.roleLabel),
                    trailing: BlocConsumer<TeamBloc, TeamState>(
                        bloc: _cancelInviteTeamBloc,
                        listener: (context, state) {
                          if (state is CancellingInviteErrorState) {
                            GetMterminal.snackBar(context, content: state.message);
                          }
                          if (state is InviteCancelledState) {
                            BlocProvider.of<TeamBloc>(context).add(GetTeamEvent(teamId: _selectedTeam.id));
                            GetMterminal.snackBar(context, content: state.message);
                          }
                        },
                        builder: (context, state) {
                          return OutlinedButton(
                              onPressed: state is CancellingInviteState
                                  ? null
                                  : () {
                                      _cancelInvite(teamInvite);
                                    },
                              child: const Text('Cancel Invite'));
                        }),
                  );
                }).toList()));
      });

  Widget get _syncCardView => TitleCard(
      title: 'Sync',
      child: ValueListenableBuilder(
          valueListenable: MTerminalSync.syncInfo,
          builder: (context, syncInfo, child) {
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('To seamlessly share the hosts with your team, sync your data with cloud.'),
                        subtitle: Text(syncInfo.status == SyncStatus.failed
                            ? 'Last sync failed.'
                            : syncInfo.status == SyncStatus.completed
                                ? 'Last synced on: ${DateFormat(Keys.ddMMMMyHmsa).format(syncInfo.lastSyncedOn!)}'
                                : 'Not synced yet'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SizedBox(height: Device.margin(context)),
                      FilledButton.tonal(
                          onPressed: syncInfo.status == SyncStatus.inProgress
                              ? null
                              : () {
                                  MTerminalSync.start;
                                },
                          child: Text(syncInfo.status == SyncStatus.inProgress ? 'Syncing...' : 'Sync Now')),
                    ],
                  ),
                ),
                if (syncInfo.status == SyncStatus.inProgress)
                  const Column(
                    children: [CircularProgressIndicator(), Text('Syncing...')],
                  )
                else
                  Icon(
                    Icons.sync,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  )
              ],
            );
          }));

  Widget get _devicesView {
    return TitleCard(
        title: 'Devices',
        child: BlocBuilder<AppDeviceBloc, AppDeviceState>(builder: (context, state) {
          final devices = <AppDevice>[];
          if (state is AppDevicesRetrievedState) {
            devices.addAll(state.appDevices);
          }
          return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: devices
                  .map((device) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(device.name),
                      subtitle: Text('Last used on ${DateFormat(Keys.ddMMMMyHma).format(device.lastActiveAt.toLocal())}')))
                  .toList());
        }));
  }

  Future<void> _cancelInvite(TeamInvite invite) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(Icons.cancel),
            title: Text(invite.user.email),
            content: const Text('Are you sure you want to cancel this invite?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Go Back')),
              ElevatedButton(
                  onPressed: () async {
                    _cancelInviteTeamBloc.add(CancelInviteEvent(teamId: _selectedTeam.id, teamInviteId: invite.id));
                    Get.back();
                  },
                  child: const Text('Yes'))
            ],
          );
        });
  }

  void _createTeamDialog() {
    final createTeamForm = GlobalKey<FormBuilderState>();
    final createTeamBloc = TeamBloc();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return BlocConsumer<TeamBloc, TeamState>(
              bloc: createTeamBloc,
              listener: (context, state) async {
                if (state is TeamCreatedState) {
                  if (context.mounted) GetMterminal.snackBar(context, content: 'Team created successfully.');
                  await UserService().me();
                  Get.back();
                } else if (state is CreatingTeamErrorState) {
                  GetMterminal.snackBar(context, content: state.message);
                }
              },
              builder: (context, state) {
                return AlertDialog(
                  icon: const Icon(Icons.group),
                  title: const Text('Create Team'),
                  content: FormBuilder(
                    key: createTeamForm,
                    child: FormBuilderTextField(
                      name: Keys.name,
                      decoration: const InputDecoration(label: Text('Team Name')),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      onSubmitted: (value) {},
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: state is CreatingTeamState ? null : Get.back, child: const Text('Cancel')),
                    FilledButton(
                        onPressed: state is CreatingTeamState
                            ? null
                            : () {
                                if (createTeamForm.currentState!.saveAndValidate()) {
                                  createTeamBloc.add(CreateTeamEvent(name: createTeamForm.currentState!.value[Keys.name]));
                                }
                              },
                        child: const Text('Create'))
                  ],
                );
              });
        });
  }
}
