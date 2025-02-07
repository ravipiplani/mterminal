import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';

part 'subscription_plan.g.dart';

@JsonSerializable()
class SubscriptionPlan {
  SubscriptionPlan(
      {required this.id,
      required this.name,
      required this.description,
      required this.features,
      required this.helpText1,
      this.helpText2,
      required this.costPerMonth,
      required this.costUnit,
      required this.currency,
      required this.isTeamPlan,
      this.appleLineItemID,
      required this.sequence});

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanFromJson(json);

  final int id;
  final String name;
  final String description;
  final List<String> features;
  @JsonKey(name: Keys.helpText1)
  final String helpText1;
  @JsonKey(name: Keys.helpText2)
  final String? helpText2;
  @JsonKey(name: Keys.costPerMonth)
  final double costPerMonth;
  @JsonKey(name: Keys.costUnit)
  final String costUnit;
  final String currency;
  @JsonKey(name: Keys.isTeamPlan)
  final bool isTeamPlan;
  @JsonKey(name: Keys.appleLineItemID)
  final String? appleLineItemID;
  final int sequence;

  Map<String, dynamic> toJson() => _$SubscriptionPlanToJson(this);

  String get planCostDisplay {
    if (costPerMonth == 0.0) {
      return 'Free';
    } else {
      return '$currency $costPerMonth';
    }
  }

  @override
  String toString() {
    return 'SubscriptionPlan{id: $id, name: $name, description: $description, features: $features, helpText1: $helpText1, helpText2: $helpText2, costPerMonth: $costPerMonth, costUnit: $costUnit currency: $currency, isTeamPlan: $isTeamPlan, appleLineItemID: $appleLineItemID, sequence: $sequence}';
  }
}
