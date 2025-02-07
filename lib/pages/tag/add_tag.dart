import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../config/keys.dart';
import '../../layout/device.dart';
import '../../models/tag.dart';
import '../../services/tag_service.dart';
import '../../utilities/get_mterminal.dart';
import '../../utilities/mterminal_sync.dart';

class AddTag extends StatefulWidget {
  const AddTag({super.key, this.tag, this.callback});

  final Tag? tag;
  final VoidCallback? callback;

  @override
  State<AddTag> createState() => _AddTagState();
}

class _AddTagState extends State<AddTag> {
  final _addTagFormKey = GlobalKey<FormBuilderState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _tagService = TagService();

  late Map<String, dynamic> _initialValue;

  @override
  void initState() {
    _initialValue = widget.tag != null ? widget.tag!.toJson() : {};
    if (widget.tag != null) {
      _initialValue.addAll({
        Keys.name: widget.tag!.name,
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Tag'),
        centerTitle: false,
        actions: [const Icon(Icons.tag), SizedBox(width: Device.margin(context))],
      ),
      body: _body,
      persistentFooterButtons: [
        if (widget.tag != null)
          IconButton(
              onPressed: () {
                _deleteTag();
              },
              icon: const Icon(Icons.delete)),
        FilledButton(
            onPressed: () async {
              if (_addTagFormKey.currentState!.saveAndValidate()) {
                final data = <String, dynamic>{};
                data.addAll(_addTagFormKey.currentState!.value);
                try {
                  if (widget.tag != null) {
                    await _tagService.update(id: widget.tag!.id, details: data);
                  } else {
                    await _tagService.insert(details: data);
                  }
                  MTerminalSync.start;
                  _goBack();
                } on DatabaseException catch (e) {
                  if (e.getResultCode() == 2067) {
                    _scaffoldMessengerKey.currentState!.showSnackBar(const SnackBar(content: Text('Failed. The tag with the given name already exists')));
                  }
                }
              }
            },
            child: Text(widget.tag != null ? 'Update' : 'Add'))
      ],
    );
  }

  Widget get _body => SingleChildScrollView(
        child: FormBuilder(
          key: _addTagFormKey,
          initialValue: _initialValue,
          child: Container(
            padding: EdgeInsets.all(Device.margin(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: Keys.name,
                  autofocus: true,
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                ),
              ],
            ),
          ),
        ),
      );

  void _goBack() {
    Get.back();
    if (widget.callback != null) {
      widget.callback!();
    }
  }

  Future<void> _deleteTag() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(Icons.delete),
            title: Text(widget.tag!.name),
            content: const Text('Are you sure you want to delete the tag?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () async {
                    await _tagService.delete(id: widget.tag!.id);
                    MTerminalSync.start;
                    if (context.mounted) GetMterminal.snackBar(context, content: 'Tag deleted successfully.');
                    Get.back();
                    _goBack();
                  },
                  child: const Text('Delete'))
            ],
          );
        });
  }
}
