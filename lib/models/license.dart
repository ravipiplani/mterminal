import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';
import 'seat.dart';
import 'subscription_plan.dart';

part 'license.g.dart';

@JsonSerializable()
class License {
  License({required this.id, required this.subscriptionPlan, required this.startDate, required this.endDate, required this.isMonthly, required this.seats});

  factory License.fromJson(Map<String, dynamic> json) => _$LicenseFromJson(json);

  final int id;
  @JsonKey(name: Keys.subscriptionPlan)
  final SubscriptionPlan subscriptionPlan;
  @JsonKey(name: Keys.startDate)
  final DateTime startDate;
  @JsonKey(name: Keys.endDate)
  final DateTime? endDate;
  @JsonKey(name: Keys.isMonthly)
  final bool isMonthly;
  @JsonKey(defaultValue: [])
  final List<Seat> seats;

  Map<String, dynamic> toJson() => _$LicenseToJson(this);

  int get totalSeats => subscriptionPlan.isTeamPlan ? seats.length : 1;

  int get occupiedSeats => subscriptionPlan.isTeamPlan ? seats.where((seat) => seat.assignedTo != null).length : 1;

  bool get areSeatsAvailable {
    return occupiedSeats < totalSeats;
  }

  @override
  String toString() {
    return 'License{id: $id, subscriptionPlan: $subscriptionPlan, startDate: $startDate, endDate: $endDate, isMonthly: $isMonthly, seats: $seats}';
  }
}
