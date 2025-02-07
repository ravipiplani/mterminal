import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../models/subscription_plan.dart';
import '../../../services/subscription_plan_service.dart';

part 'subscription_plan_event.dart';
part 'subscription_plan_state.dart';

class SubscriptionPlanBloc extends Bloc<SubscriptionPlanEvent, SubscriptionPlanState> {
  SubscriptionPlanBloc() : super(UninitializedState()) {
    on<GetSubscriptionPlansEvent>(_onGetSubscriptionPlansEvent);
  }

  final _subscriptionPlanService = SubscriptionPlanService();

  SubscriptionPlanState get initialState => UninitializedState();

  Future<void> _onGetSubscriptionPlansEvent(GetSubscriptionPlansEvent event, Emitter<SubscriptionPlanState> emit) async {
    emit(RetrievingSubscriptionPlansState());
    try {
      final subscriptionPlans = await _subscriptionPlanService.get();
      emit(SubscriptionPlansRetrievedState(subscriptionPlans: subscriptionPlans));
    } on Exception catch (e) {
      emit(RetrievingSubscriptionPlansErrorState(message: e.toString()));
    }
  }
}
