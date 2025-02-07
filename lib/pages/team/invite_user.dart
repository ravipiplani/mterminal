import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../reactive/blocs/team/team_bloc.dart';
import '../../services/user_service.dart';
import '../../utilities/get_mterminal.dart';
import '../../widgets/button_loader.dart';

class InviteUser extends StatefulWidget {
  const InviteUser({super.key, this.callback, required this.validate});

  final Function(String)? callback;
  final Function(String) validate;

  @override
  State<InviteUser> createState() => _InviteUserState();
}

class _InviteUserState extends State<InviteUser> {
  final _inviteUserForm = GlobalKey<FormBuilderState>();
  late Future<List<Map<String, dynamic>>> _futureRoleTypes;
  final _teamBloc = TeamBloc();
  final _selectedTeam = GetMterminal.selectedTeam();

  @override
  void initState() {
    _futureRoleTypes = _getRoleTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite User'),
        centerTitle: false,
        actions: [const Icon(Icons.person), SizedBox(width: Device.margin(context))],
      ),
      body: _body,
      persistentFooterButtons: [
        BlocConsumer<TeamBloc, TeamState>(
            bloc: _teamBloc,
            listener: (context, state) {
              if (state is InvitingUserErrorState) {
                GetMterminal.snackBar(context, content: state.message);
              }
              if (state is UserInvitedState) {
                BlocProvider.of<TeamBloc>(context).add(GetTeamEvent(teamId: _selectedTeam.id));
                GetMterminal.snackBar(context, content: state.message);
                Get.back();
              }
            },
            builder: (context, state) {
              return ButtonLoader(
                isLoading: state is InvitingUserState,
                width: double.infinity,
                child: FilledButton(
                    onPressed: state is InvitingUserState
                        ? null
                        : () {
                            if (_inviteUserForm.currentState!.saveAndValidate()) {
                              final values = _inviteUserForm.currentState!.value;
                              _teamBloc.add(InviteUserEvent(teamId: _selectedTeam.id, email: values[Keys.email], role: values[Keys.role]));
                            }
                          },
                    child: const Text('Send Invite')),
              );
            })
      ],
    );
  }

  Widget get _body => SingleChildScrollView(
        child: FormBuilder(
          key: _inviteUserForm,
          child: Container(
            padding: EdgeInsets.all(Device.margin(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: Keys.email,
                  decoration: const InputDecoration(label: Text('Email')),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.email()]),
                ),
                SizedBox(height: Device.margin(context)),
                FutureBuilder<List<Map<String, dynamic>>>(
                    future: _futureRoleTypes,
                    builder: (context, snapshot) {
                      final roleTypes = <Map<String, dynamic>>[];
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        roleTypes.addAll(snapshot.data!);
                      }
                      return FormBuilderDropdown<int>(
                          name: Keys.role,
                          enabled: snapshot.connectionState == ConnectionState.done,
                          decoration: const InputDecoration(label: Text('Select Role')),
                          validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                          items: roleTypes.isNotEmpty
                              ? roleTypes.map((roleType) => DropdownMenuItem<int>(value: roleType[Keys.id], child: Text(roleType[Keys.label]))).toList()
                              : []);
                    })
              ],
            ),
          ),
        ),
      );

  Future<List<Map<String, dynamic>>> _getRoleTypes() async {
    final roleTypes = await UserService().roles();
    return roleTypes;
  }
}
