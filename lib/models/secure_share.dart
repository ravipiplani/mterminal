import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';

part 'secure_share.g.dart';

@JsonSerializable()
class SecureShare {
  SecureShare(
      {required this.id,
      required this.data,
      required this.isSingleUse,
      required this.iv,
      required this.expiryAt,
      required this.accesses,
      required this.createdBy});

  factory SecureShare.fromJson(Map<String, dynamic> json) => _$SecureShareFromJson(json);

  final int id;
  final String data;
  @JsonKey(name: Keys.isSingleUse)
  final bool isSingleUse;
  final String iv;
  @JsonKey(name: Keys.expiryAt)
  final DateTime expiryAt;
  final List<int> accesses;
  @JsonKey(name: Keys.createdBy)
  final int createdBy;

  Map<String, dynamic> toJson() => _$SecureShareToJson(this);

  @override
  String toString() {
    return 'SecureShare{id: $id, data: $data, isSingleUse: $isSingleUse, iv: $iv, expiryAt: $expiryAt, accesses: $accesses, createdBy: $createdBy}';
  }
}
