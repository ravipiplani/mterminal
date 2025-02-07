part of 'subscription_plan_bloc.dart';

abstract class SubscriptionPlanState {
  SubscriptionPlanState();
}

class UninitializedState extends SubscriptionPlanState {}

//Retrieving Subscription Plans
class RetrievingSubscriptionPlansState extends SubscriptionPlanState {}

class SubscriptionPlansRetrievedState extends SubscriptionPlanState {
  SubscriptionPlansRetrievedState({required this.subscriptionPlans});

  final List<SubscriptionPlan> subscriptionPlans;

  List<Object> get props => [subscriptionPlans];
}

class RetrievingSubscriptionPlansErrorState extends SubscriptionPlanState {
  RetrievingSubscriptionPlansErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}
