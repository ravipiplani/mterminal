import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../config/keys.dart';
import '../models/host.dart';
import '../models/tag.dart';
import '../services/host_service.dart';
import '../services/tag_service.dart';
import 'get_mterminal.dart';

enum SyncStatus { notSynced, inProgress, completed, failed }

class SyncInfo {
  SyncInfo({required this.status, this.lastSyncedOn});

  final SyncStatus status;
  final DateTime? lastSyncedOn;

  SyncInfo copyWith({SyncStatus? status, DateTime? lastSyncedOn}) {
    return SyncInfo(status: status ?? this.status, lastSyncedOn: lastSyncedOn ?? this.lastSyncedOn);
  }
}

mixin MTerminalSync {
  static final _tagService = TagService();
  static final _hostService = HostService();

  static final syncInfo = ValueNotifier<SyncInfo>(SyncInfo(status: SyncStatus.notSynced));

  static Future<void> get start async {
    if (GetMterminal.isLightCustomer || kIsWeb) {
      return;
    }
    syncInfo.value = syncInfo.value.copyWith(status: SyncStatus.inProgress);
    try {
      await _syncTags();
      await _syncHosts();
      syncInfo.value = syncInfo.value.copyWith(status: SyncStatus.completed);
      syncInfo.value = syncInfo.value.copyWith(lastSyncedOn: DateTime.now());
    } on Exception catch (e) {
      debugPrint(e.toString());
      syncInfo.value = syncInfo.value.copyWith(status: SyncStatus.failed);
    }
  }

  static Future<void> _syncTags() async {
    /* sync tags
    1. Get tags from remote
        for each remote tag, check if it exists on local, if not - create it on local
    2. Get tags on local:
        Create on remote where remote_id is null
        Update local or remote based on updated_on timestamp
     */
    final remoteTags = await _tagService.get(onRemote: true, includeDeleted: true);
    final localTags = await _tagService.get(includeDeleted: true);

    // create new local tags on remote
    final tagsMissingOnRemote = localTags.where((element) => element.remoteId == null).toList();
    for (final localTag in tagsMissingOnRemote) {
      final remoteTag = await _tagService.insert(details: {Keys.name: localTag.name, Keys.deletedAt: localTag.deletedAt?.toIso8601String()}, onRemote: true);
      await _tagService.update(id: localTag.id, details: {
        Keys.remoteId: remoteTag.id,
        Keys.remoteUpdatedOn: remoteTag.updatedAt?.toLocal().toIso8601String(),
        Keys.deletedAt: remoteTag.deletedAt?.toLocal().toIso8601String()
      });
    }

    var tagsMissingOnLocal = 0;
    var localTagUpdatedOnRemote = 0;
    var remoteTagUpdatedOnLocal = 0;
    for (final remoteTag in remoteTags) {
      final localTag = localTags.firstWhereOrNull((element) => element.remoteId == remoteTag.id);
      if (localTag == null) {
        // create local tag
        tagsMissingOnLocal++;
        await _tagService.insert(details: {
          Keys.name: remoteTag.name,
          Keys.remoteId: remoteTag.id,
          Keys.remoteUpdatedOn: remoteTag.updatedAt?.toLocal().toIso8601String(),
          Keys.deletedAt: remoteTag.deletedAt?.toLocal().toIso8601String()
        });
      } else if (localTag.localUpdatedOn != null) {
        if (localTag.localUpdatedOn!.isBefore(remoteTag.updatedAt!)) {
          // update local
          remoteTagUpdatedOnLocal++;
          await _tagService.update(id: localTag.id, details: {
            Keys.name: remoteTag.name,
            Keys.localUpdatedOn: null,
            Keys.remoteUpdatedOn: remoteTag.updatedAt?.toLocal().toIso8601String(),
            Keys.deletedAt: remoteTag.deletedAt?.toLocal().toIso8601String()
          });
        } else {
          // update remote
          localTagUpdatedOnRemote++;
          final updatedRemoteTag = await _tagService.update(
              id: remoteTag.id, details: {Keys.name: localTag.name, Keys.deletedAt: localTag.deletedAt?.toIso8601String()}, includeDeleted: true, onRemote: true);
          await _tagService.update(id: localTag.id, details: {
            Keys.localUpdatedOn: null,
            Keys.remoteUpdatedOn: updatedRemoteTag.updatedAt?.toLocal().toIso8601String(),
            Keys.deletedAt: updatedRemoteTag.deletedAt?.toLocal().toIso8601String()
          });
        }
      } else if (localTag.remoteUpdatedOn != null && (localTag.remoteUpdatedOn?.isBefore(remoteTag.updatedAt!) ?? false)) {
        remoteTagUpdatedOnLocal++;
        await _tagService.update(id: localTag.id, details: {
          Keys.name: remoteTag.name,
          Keys.localUpdatedOn: null,
          Keys.remoteUpdatedOn: remoteTag.updatedAt?.toLocal().toIso8601String(),
          Keys.deletedAt: remoteTag.deletedAt?.toLocal().toIso8601String()
        });
      }
    }

    debugPrint('*************************************************');
    debugPrint('New tags created on remote: ${tagsMissingOnRemote.length}');
    debugPrint('New tags created on local: $tagsMissingOnLocal');
    debugPrint('Local tags updated on remote: $localTagUpdatedOnRemote');
    debugPrint('Remote tags updated on local: $remoteTagUpdatedOnLocal');
    debugPrint('*************************************************');
  }

  static Future<void> _syncHosts() async {
    /* sync hosts
    1. Get hosts from remote
        for each remote host, check if it exists on local, if not - create it on local
    2. Get hosts on local:
        Create on remote where remote_id is null
        Update local or remote based on updated_on timestamp
     */
    final remoteHosts = await _hostService.get(onRemote: true, includeDeleted: true);
    final localHosts = await _hostService.get(includeDeleted: true);

    // create new local hosts on remote
    final hostsMissingOnRemote = localHosts.where((element) => element.remoteId == null).toList();
    for (final localHost in hostsMissingOnRemote) {
      final data = await _buildHostPayload(host: localHost, onRemote: true);
      final remoteHost = await _hostService.insert(details: data, onRemote: true);
      await _hostService
          .update(id: localHost.id, details: {Keys.remoteId: remoteHost.id, Keys.remoteUpdatedOn: remoteHost.updatedAt?.toLocal().toIso8601String()});
    }

    var hostsMissingOnLocal = 0;
    var localHostUpdatedOnRemote = 0;
    var remoteHostUpdatedOnLocal = 0;
    for (final remoteHost in remoteHosts) {
      final localHost = localHosts.firstWhereOrNull((element) => element.remoteId == remoteHost.id);
      if (localHost == null) {
        // create local host
        hostsMissingOnLocal++;
        final data = await _buildHostPayload(host: remoteHost);
        await _hostService.insert(details: data);
      } else if (localHost.localUpdatedOn != null) {
        if (localHost.localUpdatedOn!.isBefore(remoteHost.updatedAt!)) {
          // update local
          remoteHostUpdatedOnLocal++;
          final data = await _buildHostPayload(host: remoteHost, localExists: true);
          await _hostService.update(id: localHost.id, details: data);
        } else {
          // update remote
          localHostUpdatedOnRemote++;
          final data = await _buildHostPayload(host: localHost, onRemote: true);
          final updatedRemoteHost = await _hostService.update(id: remoteHost.id, details: data, includeDeleted: true, onRemote: true);
          await _hostService
              .update(id: localHost.id, details: {Keys.localUpdatedOn: null, Keys.remoteUpdatedOn: updatedRemoteHost.updatedAt?.toLocal().toIso8601String()});
        }
      } else if (localHost.remoteUpdatedOn != null && (localHost.remoteUpdatedOn?.isBefore(remoteHost.updatedAt!) ?? false)) {
        remoteHostUpdatedOnLocal++;
        final data = await _buildHostPayload(host: remoteHost, localExists: true);
        await _hostService.update(id: localHost.id, details: data);
      }
    }

    debugPrint('*************************************************');
    debugPrint('New hosts created on remote: ${hostsMissingOnRemote.length}');
    debugPrint('New hosts created on local: $hostsMissingOnLocal');
    debugPrint('Local hosts updated on remote: $localHostUpdatedOnRemote');
    debugPrint('Remote hosts updated on local: $remoteHostUpdatedOnLocal');
    debugPrint('*************************************************');
  }

  static Future<Map<String, dynamic>> _buildHostPayload({required Host host, bool onRemote = false, bool localExists = false}) async {
    final data = <String, dynamic>{
      Keys.name: host.name,
      Keys.address: host.address,
      Keys.port: host.port,
      Keys.username: host.username,
      Keys.deletedAt: host.deletedAt?.toLocal().toIso8601String()
    };
    Tag? tag;
    if (!onRemote) {
      // 'host' is remoteHost
      if (host.tag != null) {
        tag = await _tagService.getByRemoteId(remoteId: host.tag!.id);
      }
      data.addAll({Keys.remoteId: host.id, Keys.remoteUpdatedOn: host.updatedAt?.toLocal().toIso8601String(), Keys.tagId: tag?.id});
      if (localExists) {
        data.addAll({Keys.localUpdatedOn: null});
      }
    } else {
      // 'host' is localHost
      if (host.tag != null) {
        tag = await _tagService.getById(id: host.tag!.id);
      }
      data.addAll({Keys.tagId: tag?.remoteId});
    }
    return data;
  }
}
