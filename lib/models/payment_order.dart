import 'package:json_annotation/json_annotation.dart';

import '../config/keys.dart';

part 'payment_order.g.dart';

enum Gateway {
  @JsonValue(1)
  razorpay,
  @JsonValue(2)
  apple
}

@JsonSerializable()
class PaymentOrder {
  PaymentOrder(this.currency, {
    required this.id,
    required this.gateway,
    this.orderId,
    required this.amount,
    required this.key,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) => _$PaymentOrderFromJson(json);

  final int id;
  final Gateway gateway;
  @JsonKey(name: Keys.orderId)
  final String? orderId;
  final int amount;
  final String currency;
  final String key;

  Map<String, dynamic> toJson() => _$PaymentOrderToJson(this);

  @override
  String toString() {
    return 'PaymentOrder{id: $id, gateway: $gateway, orderId: $orderId, amount: $amount, currency: $currency, key: $key}';
  }
}
