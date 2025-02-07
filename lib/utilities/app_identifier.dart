import 'dart:async' show Future;
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

mixin AppIdentifier {
  static late String _id;

  static String get id => _id;

  static Future<File> _getFile() async {
    final applicationDirectory = await getApplicationSupportDirectory();
    final filePath = join(applicationDirectory.path, 'identifier');
    final file = File(filePath);
    return file;
  }

  static Future<void> get initialize async {
    final file = await _getFile();
    final fileExists = await file.exists();
    if (fileExists) {
      _id = await file.readAsString();
    } else {
      const uuid = Uuid();
      final uniqueID = uuid.v4();
      await file.writeAsString(uniqueID, flush: true);
      _id = uniqueID;
    }
  }

  static Future<void> get remove async {
    final file = await _getFile();
    final fileExists = await file.exists();
    if (fileExists) {
      await file.delete();
    }
  }
}
