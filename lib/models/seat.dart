import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';
import 'user.dart';

part 'seat.g.dart';

@JsonSerializable()
class Seat {
  Seat({required this.id, this.assignedTo});

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);

  final int id;
  @JsonKey(name: Keys.assignedTo)
  final User? assignedTo;

  Map<String, dynamic> toJson() => _$SeatToJson(this);

  @override
  String toString() {
    return 'Seat{id: $id, assignedTo: $assignedTo}';
  }
}
