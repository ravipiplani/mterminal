import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../config/endpoint.dart';
import '../config/keys.dart';
import '../models/tag.dart';
import '../utilities/db.dart';
import '../utilities/preferences.dart';
import 'api_client.dart';

class TagService {
  final _database = DB.instance;
  final _table = 'tags';
  static final _client = ApiClient().init(baseUrl: Endpoint.baseUrl, isTeamClient: true);
  final _teamId = Preferences.getInt(Keys.selectedTeamId);

  Future<List<Tag>> get({bool includeDeleted = false, bool onRemote = false}) async {
    var tags = [];
    if (onRemote) {
      final response = await _client.get(Endpoint.tags, queryParameters: {if (includeDeleted) Keys.includeDeleted: Keys.yes});
      tags = response.data[Keys.results] as List;
    } else {
      if (includeDeleted) {
        tags = await _database.query(_table, where: 'team_id = ?', whereArgs: [_teamId]);
      } else {
        tags = await _database.query(_table, where: 'team_id = ? and deleted_at is ?', whereArgs: [_teamId, null]);
      }
    }
    return tags.map((e) => Tag.fromJson(e)).toList();
  }

  Future<Tag> getById({required int id}) async {
    final tags = await _database.query(_table, where: 'id = ?', whereArgs: [id]);
    return Tag.fromJson(tags.first);
  }

  Future<Tag> getByRemoteId({required int remoteId}) async {
    final tags = await _database.query(_table, where: 'remote_id = ?', whereArgs: [remoteId]);
    return Tag.fromJson(tags.first);
  }

  Future<Tag> insert({required Map<String, dynamic> details, bool onRemote = false}) async {
    late Map<String, dynamic> tagData;
    if (onRemote) {
      final response = await _client.post(Endpoint.tags, data: details);
      tagData = response.data as Map<String, dynamic>;
    } else {
      details[Keys.teamId] = _teamId;
      final tagId = await _database.insert(
        _table,
        details,
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      final tags = await _database.query(_table, where: 'id = ?', whereArgs: [tagId]);
      tagData = tags.first;
    }
    return Tag.fromJson(tagData);
  }

  Future<Tag> update({required int id, required Map<String, dynamic> details, bool includeDeleted = false, bool onRemote = false}) async {
    late Map<String, dynamic> tagData;
    if (onRemote) {
      final response =
          await _client.patch(Endpoint.tag.replaceAll(':id', id.toString()), data: details, queryParameters: {if (includeDeleted) Keys.includeDeleted: true});
      tagData = response.data as Map<String, dynamic>;
    } else {
      final data = Map<String, dynamic>.from(details);
      await _database.update(_table, data, where: 'id = ?', whereArgs: [id]);
      final tags = await _database.query(_table, where: 'id = ?', whereArgs: [id]);
      tagData = tags.first;
    }
    return Tag.fromJson(tagData);
  }

  Future<void> delete({required int id}) async {
    const uuid = Uuid();
    await _database.update(_table,
        {Keys.name: uuid.v4(), Keys.localUpdatedOn: DateTime.now().toLocal().toIso8601String(), Keys.deletedAt: DateTime.now().toLocal().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    await _database.delete(_table, where: 'team_id = ?', whereArgs: [_teamId]);
  }
}
