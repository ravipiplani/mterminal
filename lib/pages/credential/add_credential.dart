import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../models/credential.dart';
import '../../services/credential_service.dart';
import '../../utilities/get_mterminal.dart';

class AddCredential extends StatefulWidget {
  const AddCredential({super.key, this.credential, this.callback});

  final Credential? credential;
  final VoidCallback? callback;

  @override
  State<AddCredential> createState() => _AddCredentialState();
}

class _AddCredentialState extends State<AddCredential> with SingleTickerProviderStateMixin {
  final _addKeyForm = GlobalKey<FormBuilderState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late TabController _tabController;
  final _keyNameTextController = TextEditingController();
  final _privateKeyTextController = TextEditingController();

  final _tabs = ['Key', 'Username/Password'];
  final _credentialService = CredentialService();

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: _tabs.length);
    if (widget.credential != null) {
      _keyNameTextController.value = TextEditingValue(text: widget.credential!.name);
      _privateKeyTextController.value = TextEditingValue(text: widget.credential!.privateKey!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Credential'),
          centerTitle: false,
          actions: [const Icon(Icons.key), SizedBox(width: Device.margin(context))],
          bottom: widget.credential == null
              ? TabBar(
                  controller: _tabController,
                  tabs: _tabs.map((e) => Text(e)).toList(),
                )
              : null,
        ),
        body: widget.credential == null
            ? TabBarView(
                controller: _tabController,
                children: [
                  _addKeyView,
                  _addCredentialsView,
                ],
              )
            : widget.credential!.type == CredentialType.pemKey
                ? _addKeyView
                : _addCredentialsView,
        persistentFooterButtons: [
          if (widget.credential != null)
            IconButton(
                onPressed: () {
                  _deleteCredential();
                },
                icon: const Icon(Icons.delete)),
          FilledButton(
              onPressed: () {
                if (_tabController.index == 0 || (widget.credential!.type == CredentialType.pemKey)) {
                  _addKey();
                } else {}
              },
              child: Text(widget.credential != null ? 'Update' : 'Add'))
        ],
      ),
    );
  }

  Widget get _addKeyView => SingleChildScrollView(
        child: FormBuilder(
          key: _addKeyForm,
          child: Container(
            padding: EdgeInsets.all(Device.margin(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: Keys.name,
                  controller: _keyNameTextController,
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                ),
                SizedBox(height: Device.margin(context)),
                TextButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pem']);
                      if (result != null) {
                        final file = File(result.files.single.path!);
                        try {
                          final key = (await file.readAsString()).replaceAll('\r\n', '\n');
                          SSHKeyPair.fromPem(key);
                          _privateKeyTextController.value = TextEditingValue(text: key);
                          _keyNameTextController.value = TextEditingValue(text: file.path.split('/').last.split('.').first);
                        } on FormatException {
                          _scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(content: Text('Invalid private key.')));
                        }
                      }
                    },
                    child: const Text('Select Private Key')),
                SizedBox(height: Device.margin(context)),
                FormBuilderTextField(
                    name: Keys.privateKey, maxLines: 6, controller: _privateKeyTextController, decoration: const InputDecoration(label: Text('Private Key')))
              ],
            ),
          ),
        ),
      );

  Future<void> _addKey() async {
    if (_addKeyForm.currentState!.saveAndValidate()) {
      final data = <String, dynamic>{Keys.type: 2};
      data.addAll(_addKeyForm.currentState!.value);
      try {
        if (widget.credential != null) {
          _credentialService.update(id: widget.credential!.id, details: data);
        } else {
          _credentialService.insert(details: data);
        }
        _goBack();
        GetMterminal.snackBar(context, content: 'Key ${widget.credential != null ? 'updated' : 'added'} successfully.');
      } on DatabaseException catch (e) {
        if (e.getResultCode() == 2067) {
          _scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(content: Text('Failed. The key with the given name already exists')));
        }
      }
    }
  }

  Widget get _addCredentialsView {
    return Center(
      child: Text('Coming Soon', style: Theme.of(context).textTheme.titleLarge,),
    );
    return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Device.margin(context)),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(label: Text('Name')),
              ),
              SizedBox(height: Device.margin(context)),
              TextFormField(
                decoration: const InputDecoration(label: Text('Username')),
              ),
              SizedBox(height: Device.margin(context)),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(label: Text('Password')),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _deleteCredential() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(Icons.delete),
            title: Text(widget.credential!.name),
            content: const Text('Are you sure you want to delete this credential?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () async {
                    _credentialService.delete(id: widget.credential!.id).then((value) {
                      Get.back();
                      _goBack();
                      GetMterminal.snackBar(context, content: 'Credential deleted successfully.');
                    });
                  },
                  child: const Text('Delete'))
            ],
          );
        });
  }

  void _goBack() {
    Get.back();
    if (widget.callback != null) {
      widget.callback!();
    }
  }
}
