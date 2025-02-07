// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
      dueOn: DateTime.parse(json['due_on'] as String),
      subscriptionPlanId: json['subscription_plan_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      isAttempted: json['is_attempted'] as bool,
      isPaid: json['is_paid'] as bool,
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      url: json['url'] as String?,
      id: json['id'] as int,
      amount: json['amount'] as int,
      number: json['number'] as String,
    );

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
      'id': instance.id,
      'subscription_plan_id': instance.subscriptionPlanId,
      'amount': instance.amount,
      'number': instance.number,
      'due_on': instance.dueOn.toIso8601String(),
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'is_attempted': instance.isAttempted,
      'is_paid': instance.isPaid,
      'paid_at': instance.paidAt?.toIso8601String(),
      'url': instance.url,
    };
