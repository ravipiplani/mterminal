import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';

part 'release_info.g.dart';

enum Platform {
  @JsonValue('macOS')
  macOS
}

@JsonSerializable()
class ReleaseInfo {
  ReleaseInfo({required this.platform, required this.version, required this.number, required this.date, required this.notes, required this.binaryUrl});

  factory ReleaseInfo.fromJson(Map<String, dynamic> json) => _$ReleaseInfoFromJson(json);

  final Platform platform;
  final String version;
  final String number;
  final DateTime date;
  final String notes;
  @JsonKey(name: Keys.binaryUrl)
  final String binaryUrl;

  Map<String, dynamic> toJson() => _$ReleaseInfoToJson(this);

  @override
  String toString() {
    return 'ReleaseInfo{platform: $platform, version: $version, number: $number, date: $date, notes: $notes, binaryUrl: $binaryUrl}';
  }
}
