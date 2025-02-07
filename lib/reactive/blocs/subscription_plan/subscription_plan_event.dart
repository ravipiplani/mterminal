part of 'subscription_plan_bloc.dart';

abstract class SubscriptionPlanEvent {}

class UninitializedEvent extends SubscriptionPlanEvent {}

class GetSubscriptionPlansEvent extends SubscriptionPlanEvent {}
