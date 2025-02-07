// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'license.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

License _$LicenseFromJson(Map<String, dynamic> json) => License(
      id: json['id'] as int,
      subscriptionPlan: SubscriptionPlan.fromJson(
          json['subscription_plan'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      isMonthly: json['is_monthly'] as bool,
      seats: (json['seats'] as List<dynamic>?)
              ?.map((e) => Seat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$LicenseToJson(License instance) => <String, dynamic>{
      'id': instance.id,
      'subscription_plan': instance.subscriptionPlan,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'is_monthly': instance.isMonthly,
      'seats': instance.seats,
    };
