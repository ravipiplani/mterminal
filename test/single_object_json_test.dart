// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('single object json parsing', () {
    const str =
        '{"id":1046,"document_type":1,"company":124,"irn":null,"status":"Yet to Initiate","signed_document":null,"agreement_company_aggreement_legality":[]}';
    final schemeJson = jsonDecode(str);
  });
}
