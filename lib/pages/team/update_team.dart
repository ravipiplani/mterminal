import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../models/team.dart';
import '../../reactive/blocs/team/team_bloc.dart';
import '../../utilities/get_mterminal.dart';
import '../../widgets/button_loader.dart';

class UpdateTeam extends StatefulWidget {
  const UpdateTeam({super.key, required this.team, this.onSuccess});

  final Team team;
  final VoidCallback? onSuccess;

  @override
  State<UpdateTeam> createState() => _UpdateTeamState();
}

class _UpdateTeamState extends State<UpdateTeam> {
  final _updateTeamForm = GlobalKey<FormBuilderState>();
  final _teamBloc = TeamBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Team'),
        centerTitle: false,
        actions: [const Icon(Icons.people), SizedBox(width: Device.margin(context))],
      ),
      body: _body,
      persistentFooterButtons: [
        BlocConsumer<TeamBloc, TeamState>(
            bloc: _teamBloc,
            listener: (context, state) {
              if (state is UpdatingTeamErrorState) {
                GetMterminal.snackBar(context, content: state.message);
              }
              if (state is TeamUpdatedState) {
                BlocProvider.of<TeamBloc>(context).add(GetTeamEvent(teamId: widget.team.id));
                GetMterminal.snackBar(context, content: 'Team updated successfully.');
                if (widget.onSuccess != null) {
                  widget.onSuccess!();
                }
                Get.back();
              }
            },
            builder: (context, state) {
              return ButtonLoader(
                isLoading: state is UpdatingTeamState,
                width: double.infinity,
                child: FilledButton(
                    onPressed: state is UpdatingTeamState
                        ? null
                        : () {
                            if (_updateTeamForm.currentState!.saveAndValidate()) {
                              final values = _updateTeamForm.currentState!.value;
                              _teamBloc.add(UpdateTeamEvent(teamId: widget.team.id, data: values));
                            }
                          },
                    child: const Text('Update Team')),
              );
            })
      ],
    );
  }

  Widget get _body => SingleChildScrollView(
        child: FormBuilder(
          key: _updateTeamForm,
          initialValue: {Keys.name: widget.team.name},
          child: Container(
            padding: EdgeInsets.all(Device.margin(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: Keys.name,
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                )
              ],
            ),
          ),
        ),
      );
}
