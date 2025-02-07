import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';

part 'invoice.g.dart';

@JsonSerializable()
class Invoice {
  Invoice(
      {required this.dueOn,
      required this.subscriptionPlanId,
      required this.startDate,
      this.endDate,
      required this.isAttempted,
      required this.isPaid,
      required this.paidAt,
      this.url,
      required this.id,
      required this.amount,
      required this.number});

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

  final int id;
  @JsonKey(name: Keys.subscriptionPlanId)
  final int subscriptionPlanId;
  final int amount;
  final String number;
  @JsonKey(name: Keys.dueOn)
  final DateTime dueOn;
  @JsonKey(name: Keys.startDate)
  final DateTime startDate;
  @JsonKey(name: Keys.endDate)
  final DateTime? endDate;
  @JsonKey(name: Keys.isAttempted)
  final bool isAttempted;
  @JsonKey(name: Keys.isPaid)
  final bool isPaid;
  @JsonKey(name: Keys.paidAt)
  final DateTime? paidAt;
  final String? url;

  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  @override
  String toString() {
    return 'Invoice{id: $id, amount: $amount, number: $number, subscriptionPlanId: $subscriptionPlanId, dueOn: $dueOn startDate: $startDate, endDate: $endDate, isAttempted: $isAttempted, isPaid: $isPaid, paidAt: $paidAt, url: $url}';
  }
}
