import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../config/endpoint.dart';
import '../config/keys.dart';
import '../models/host.dart';
import '../utilities/db.dart';
import '../utilities/preferences.dart';
import 'api_client.dart';
import 'credential_service.dart';
import 'tag_service.dart';

class HostService {
  final _database = DB.instance;
  final _table = 'hosts';
  final _credentialService = CredentialService();
  final _tagService = TagService();
  static final _client = ApiClient().init(baseUrl: Endpoint.baseUrl, isTeamClient: true);
  final _teamId = Preferences.getInt(Keys.selectedTeamId);

  Future<List<Host>> get({bool includeDeleted = false, bool onRemote = false}) async {
    var hosts = [];
    if (onRemote) {
      final response = await _client.get(Endpoint.hosts, queryParameters: {if (includeDeleted) Keys.includeDeleted: Keys.yes});
      hosts = response.data[Keys.results] as List;
    } else {
      if (includeDeleted) {
        hosts = await _database.query(_table, where: 'team_id = ?', whereArgs: [_teamId]);
      } else {
        hosts = await _database.query(_table, where: 'team_id = ? and deleted_at is ?', whereArgs: [_teamId, null]);
      }
      hosts = await _enrichHosts(hosts as List<Map<String, dynamic>>);
    }
    return hosts.map((e) => Host.fromJson(e)).toList();
  }

  Future<Host> getById({required int id}) async {
    var hosts = await _database.query(_table, where: 'id = ?', whereArgs: [id]);
    hosts = await _enrichHosts(hosts);
    return Host.fromJson(hosts.first);
  }

  Future<Host> insert({required Map<String, dynamic> details, bool onRemote = false}) async {
    late Map<String, dynamic> hostData;
    if (onRemote) {
      final response = await _client.post(Endpoint.hosts, data: details);
      hostData = response.data as Map<String, dynamic>;
    } else {
      details[Keys.teamId] = _teamId;
      final hostId = await _database.insert(
        _table,
        details,
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      var hosts = await _database.query(_table, where: 'id = ?', whereArgs: [hostId]);
      hosts = await _enrichHosts(hosts);
      hostData = hosts.first;
    }
    return Host.fromJson(hostData);
  }

  Future<Host> update({required int id, required Map<String, dynamic> details, bool includeDeleted = false, bool onRemote = false}) async {
    late Map<String, dynamic> hostData;
    if (onRemote) {
      final response =
          await _client.patch(Endpoint.host.replaceAll(':id', id.toString()), data: details, queryParameters: {if (includeDeleted) Keys.includeDeleted: true});
      hostData = response.data as Map<String, dynamic>;
    } else {
      final data = Map<String, dynamic>.from(details);
      data.addAll({Keys.localUpdatedOn: DateTime.now().toLocal().toIso8601String()});
      await _database.update(_table, data, where: 'id = ?', whereArgs: [id]);
      final hosts = await _database.query(_table, where: 'id = ?', whereArgs: [id]);
      hostData = hosts.first;
    }
    return Host.fromJson(hostData);
  }

  Future<void> delete({required int id}) async {
    const uuid = Uuid();
    await _database.update(
        _table, {Keys.name: uuid.v4(), Keys.localUpdatedOn: DateTime.now().toLocal().toIso8601String(), Keys.deletedAt: DateTime.now().toLocal().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> _enrichHosts(List<Map<String, dynamic>> hosts) async {
    final enrichedHosts = <Map<String, dynamic>>[];
    for (final host in hosts) {
      final tempHost = Map<String, dynamic>.from(host);

      if (host['credential_id'] != null) {
        final credential = await _credentialService.getById(id: int.parse(host['credential_id'].toString()));
        tempHost['credential'] = credential.toJson();
        tempHost.remove('credential_id');
      }

      if (host['tag_id'] != null) {
        final tag = await _tagService.getById(id: int.parse(host['tag_id'].toString()));
        tempHost['tag'] = tag.toJson();
        tempHost.remove('tag_id');
      }

      enrichedHosts.add(tempHost);
    }
    return enrichedHosts;
  }

  Future<void> deleteAll() async {
    await _database.delete(_table, where: 'team_id = ?', whereArgs: [_teamId]);
  }
}
