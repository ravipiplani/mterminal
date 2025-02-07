// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentOrder _$PaymentOrderFromJson(Map<String, dynamic> json) => PaymentOrder(
      json['currency'] as String,
      id: json['id'] as int,
      gateway: $enumDecode(_$GatewayEnumMap, json['gateway']),
      orderId: json['order_id'] as String?,
      amount: json['amount'] as int,
      key: json['key'] as String,
    );

Map<String, dynamic> _$PaymentOrderToJson(PaymentOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gateway': _$GatewayEnumMap[instance.gateway]!,
      'order_id': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'key': instance.key,
    };

const _$GatewayEnumMap = {
  Gateway.razorpay: 1,
  Gateway.apple: 2,
};
