import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';
import 'credential.dart';
import 'tag.dart';

part 'host.g.dart';

@JsonSerializable()
class Host {
  Host(
      {this.updatedAt,
      this.remoteId,
      this.localUpdatedOn,
      this.remoteUpdatedOn,
      required this.address,
      required this.port,
      required this.username,
      this.credential,
      required this.id,
      required this.name,
      this.tag,
      this.deletedAt});

  factory Host.fromJson(Map<String, dynamic> json) => _$HostFromJson(json);

  final int id;
  final String name;
  final String address;
  final int port;
  final String username;
  final Credential? credential;
  final Tag? tag;
  @JsonKey(name: Keys.deletedAt)
  final DateTime? deletedAt;
  @JsonKey(name: Keys.remoteId)
  final int? remoteId;
  @JsonKey(name: Keys.localUpdatedOn)
  final DateTime? localUpdatedOn;
  @JsonKey(name: Keys.remoteUpdatedOn)
  final DateTime? remoteUpdatedOn;
  @JsonKey(name: Keys.updatedAt)
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$HostToJson(this);

  Host copyWith({String? name}) {
    return Host(
        id: id,
        name: name ?? this.name,
        address: address,
        port: port,
        username: username,
        credential: credential,
        tag: tag,
        deletedAt: deletedAt,
        remoteId: remoteId,
        localUpdatedOn: localUpdatedOn,
        remoteUpdatedOn: remoteUpdatedOn,
        updatedAt: updatedAt);
  }

  @override
  String toString() {
    return 'Host{id: $id, name: $name, address: $address, port: $port, username: $username, credential: $credential, tag: $tag, deletedAt: $deletedAt, remoteId: $remoteId, localUpdatedOn: $localUpdatedOn, remoteUpdatedOn: $remoteUpdatedOn, updatedAt: $updatedAt}';
  }
}
