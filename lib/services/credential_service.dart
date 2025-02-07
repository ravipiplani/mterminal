import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../config/keys.dart';
import '../models/credential.dart';
import '../utilities/db.dart';
import '../utilities/preferences.dart';

class CredentialService {
  final _database = DB.instance;
  final _table = 'credentials';
  final _teamId = Preferences.getInt(Keys.selectedTeamId);

  Future<List<Credential>> get({bool includeDeleted = false}) async {
    final credentials = await _database.query(_table, where: 'team_id is ? and deleted_at is ?', whereArgs: [_teamId, null]);
    return credentials.map((e) => Credential.fromJson(e)).toList();
  }

  Future<Credential> getById({required int id}) async {
    final credentials = await _database.query(_table, where: 'id = ?', whereArgs: [id]);
    return Credential.fromJson(credentials.first);
  }

  Future<Credential> insert({required Map<String, dynamic> details}) async {
    details[Keys.teamId] = _teamId;
    final credentialId = await _database.insert(
      _table,
      details,
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    final credentials = await _database.query(_table, where: 'id = ?', whereArgs: [credentialId]);
    return Credential.fromJson(credentials.first);
  }

  Future<void> update({required int id, required Map<String, dynamic> details}) async {
    await _database.update(_table, details, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete({required int id}) async {
    const uuid = Uuid();
    await _database.update(_table, {Keys.name: uuid.v4(), Keys.deletedAt: DateFormat('y-MM-dd HH:mm:ss').format(DateTime.now())},
        where: 'id = ?', whereArgs: [id]);
    await _database.update('hosts', {Keys.credentialId: null}, where: 'credential_id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    await _database.delete(_table, where: 'team_id = ?', whereArgs: [_teamId]);
  }
}
