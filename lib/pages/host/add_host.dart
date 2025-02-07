import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';
import 'package:sqflite/sqflite.dart';

import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../models/credential.dart';
import '../../models/host.dart';
import '../../models/tag.dart';
import '../../reactive/blocs/credential/credential_bloc.dart';
import '../../reactive/blocs/tag/tag_bloc.dart';
import '../../services/host_service.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/mterminal_sync.dart';
import '../credential/add_credential.dart';
import '../tag/add_tag.dart';

class AddHost extends StatefulWidget {
  const AddHost({super.key, this.host, this.callback});

  final Host? host;
  final Function(Host)? callback;

  @override
  State<AddHost> createState() => _AddHostState();
}

class _AddHostState extends State<AddHost> {
  final _addHostForm = GlobalKey<FormBuilderState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _hostService = HostService();

  late Map<String, dynamic> _initialValue;
  late Host _host;

  @override
  void initState() {
    _getTags();
    _getCredentials();
    _initialValue = widget.host != null ? widget.host!.toJson() : {};
    if (widget.host != null) {
      _initialValue.addAll({
        Keys.credentialId: widget.host!.credential?.id,
        Keys.tagId: widget.host!.tag?.id,
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Host'),
        centerTitle: false,
        actions: [const Icon(Icons.computer), SizedBox(width: Device.margin(context))],
      ),
      body: _body,
      persistentFooterButtons: [
        if (widget.host != null)
          IconButton(
              onPressed: () {
                _deleteHost();
              },
              icon: const Icon(Icons.delete)),
        FilledButton(
            onPressed: () async {
              if (_addHostForm.currentState!.saveAndValidate()) {
                final data = <String, dynamic>{};
                data.addAll(_addHostForm.currentState!.value);
                try {
                  if (widget.host != null) {
                    await _hostService.update(id: widget.host!.id, details: data);
                    _host = await _hostService.getById(id: widget.host!.id);
                  } else {
                    _host = await _hostService.insert(details: data);
                  }
                  MTerminalSync.start;
                  if (context.mounted) GetMterminal.snackBar(context, content: 'Host ${widget.host != null ? 'updated' : 'added'} successfully.');
                  _goBack();
                } on DatabaseException catch (e) {
                  if (e.getResultCode() == 2067) {
                    _scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(
                      content: Text('Failed. The host with the given name already exists'),
                    ));
                  }
                }
              }
            },
            child: Text(widget.host != null ? 'UPDATE HOST' : 'ADD HOST'))
      ],
    );
  }

  Widget get _body => SingleChildScrollView(
        child: FormBuilder(
          key: _addHostForm,
          initialValue: _initialValue,
          child: Container(
            padding: EdgeInsets.all(Device.margin(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: Keys.name,
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                ),
                SizedBox(height: Device.margin(context)),
                FormBuilderTextField(
                  name: Keys.address,
                  decoration: const InputDecoration(label: Text('Address')),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                ),
                SizedBox(height: Device.margin(context)),
                FormBuilderTextField(
                  name: Keys.port,
                  initialValue: '22',
                  decoration: const InputDecoration(label: Text('Port')),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                ),
                SizedBox(height: Device.margin(context)),
                FormBuilderTextField(
                  name: Keys.username,
                  decoration: const InputDecoration(label: Text('Username')),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                ),
                SizedBox(height: Device.margin(context)),
                BlocBuilder<CredentialBloc, CredentialState>(builder: (context, state) {
                  var credentials = <Credential>[];
                  if (state is CredentialsRetrievedState) {
                    credentials = state.credentials;
                  }
                  return FormBuilderDropdown<int>(
                      name: credentials.isNotEmpty ? Keys.credentialId : 'temp1',
                      enabled: credentials.isNotEmpty,
                      decoration: const InputDecoration(label: Text('Credential')),
                      items: credentials.isNotEmpty
                          ? credentials.map((credential) => DropdownMenuItem<int>(value: credential.id, child: Text(credential.name))).toList()
                          : []);
                }),
                TextButton(
                    onPressed: () {
                      showModalSideSheet(
                          context: context,
                          width: Device.isMobile(context) ? Device.width(context) : null,
                          withCloseControll: false,
                          body: AddCredential(callback: _getCredentials));
                    },
                    child: const Text('Add Credential')),
                SizedBox(height: Device.margin(context)),
                BlocBuilder<TagBloc, TagState>(builder: (context, state) {
                  var tags = <Tag>[];
                  if (state is TagsRetrievedState) {
                    tags = state.tags;
                  }
                  return FormBuilderDropdown<int>(
                      name: tags.isNotEmpty ? Keys.tagId : 'temp2',
                      enabled: tags.isNotEmpty,
                      decoration: const InputDecoration(label: Text('Tag')),
                      items: tags.isNotEmpty ? tags.map((tag) => DropdownMenuItem<int>(value: tag.id, child: Text(tag.name))).toList() : []);
                }),
                TextButton(
                    onPressed: () {
                      showModalSideSheet(
                          context: context,
                          width: Device.isMobile(context) ? Device.width(context) : null,
                          withCloseControll: false,
                          body: AddTag(callback: _getTags));
                    },
                    child: const Text('Add Tag')),
              ],
            ),
          ),
        ),
      );

  void _goBack() {
    Get.back();
    if (widget.callback != null) {
      widget.callback!(_host);
    }
  }

  Future<void> _deleteHost() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(Icons.delete),
            title: Text(widget.host!.name),
            content: const Text('Are you sure you want to delete the host?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () async {
                    await _hostService.delete(id: widget.host!.id);
                    MTerminalSync.start;
                    if (context.mounted) GetMterminal.snackBar(context, content: 'Host deleted successfully.');
                    Get.back(); // to close confirmation popup
                    _goBack(); // to close sidesheet
                  },
                  child: const Text('Delete'))
            ],
          );
        });
  }

  void _getCredentials() {
    BlocProvider.of<CredentialBloc>(context).add(GetCredentialsEvent());
  }

  void _getTags() {
    BlocProvider.of<TagBloc>(context).add(GetTagsEvent());
  }
}
