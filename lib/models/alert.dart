import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';

part 'alert.g.dart';

enum Priority {
  @JsonValue(0)
  low,
  @JsonValue(1)
  medium,
  @JsonValue(2)
  high
}

@JsonSerializable()
class Alert {
  Alert({required this.id, required this.title, required this.priority, required this.createdAt, this.expiryAt, this.link});

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);

  final String id;
  final String title;
  final Priority priority;
  @JsonKey(name: Keys.createdAt)
  final DateTime createdAt;
  @JsonKey(name: Keys.expiryAt)
  final DateTime? expiryAt;
  final String? link;

  Map<String, dynamic> toJson() => _$AlertToJson(this);

  Color? get priorityColor {
    if (priority == Priority.high) {
      return Colors.red;
    } else if (priority == Priority.medium) {
      return Colors.orange;
    } else {
      return null;
    }
  }

  @override
  String toString() {
    return 'Alert{id: $id, title: $title, priority: $priority, createdAt: $createdAt, expiryAt: $expiryAt, link: $link}';
  }
}
