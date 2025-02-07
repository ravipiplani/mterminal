// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Seat _$SeatFromJson(Map<String, dynamic> json) => Seat(
      id: json['id'] as int,
      assignedTo: json['assigned_to'] == null
          ? null
          : User.fromJson(json['assigned_to'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SeatToJson(Seat instance) => <String, dynamic>{
      'id': instance.id,
      'assigned_to': instance.assignedTo,
    };
