// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) =>
    SubscriptionPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      helpText1: json['help_text1'] as String,
      helpText2: json['help_text2'] as String?,
      costPerMonth: (json['cost_per_month'] as num).toDouble(),
      costUnit: json['cost_unit'] as String,
      currency: json['currency'] as String,
      isTeamPlan: json['is_team_plan'] as bool,
      appleLineItemID: json['apple_line_item_id'] as String?,
      sequence: json['sequence'] as int,
    );

Map<String, dynamic> _$SubscriptionPlanToJson(SubscriptionPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'features': instance.features,
      'help_text1': instance.helpText1,
      'help_text2': instance.helpText2,
      'cost_per_month': instance.costPerMonth,
      'cost_unit': instance.costUnit,
      'currency': instance.currency,
      'is_team_plan': instance.isTeamPlan,
      'apple_line_item_id': instance.appleLineItemID,
      'sequence': instance.sequence,
    };
