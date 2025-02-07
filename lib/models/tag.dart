import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag {
  Tag({this.updatedAt, this.remoteId, this.localUpdatedOn, this.remoteUpdatedOn, required this.id, required this.name, this.deletedAt});

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  final int id;
  final String name;
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

  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  String toString() {
    return 'Tag{id: $id, name: $name, deletedAt: $deletedAt, $remoteId, localUpdatedOn: $localUpdatedOn, remoteUpdatedOn: $remoteUpdatedOn, updatedAt: $updatedAt}';
  }
}
