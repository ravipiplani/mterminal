import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../models/secure_share.dart';
import '../../../services/secure_share_service.dart';

part 'secure_share_event.dart';
part 'secure_share_state.dart';

class SecureShareBloc extends Bloc<SecureShareEvent, SecureShareState> {
  SecureShareBloc() : super(UninitializedState()) {
    on<GetSecureSharesEvent>(_onGetSecureSharesEvent);
    on<CreateSecureShareEvent>(_onCreateSecureShareEvent);
    on<DeleteSecureShareEvent>(_onDeleteSecureShareEvent);
    on<UpdateSecureShareEvent>(_onUpdateSecureShareEvent);
  }

  final _secureShareService = SecureShareService();

  SecureShareState get initialState => UninitializedState();

  Future<void> _onGetSecureSharesEvent(GetSecureSharesEvent event, Emitter<SecureShareState> emit) async {
    emit(RetrievingSecureSharesState());
    try {
      final secureShares = await _secureShareService.get();
      emit(SecureSharesRetrievedState(secureShares: secureShares));
    } on Exception catch (e) {
      emit(RetrievingSecureSharesErrorState(message: e.toString()));
    }
  }

  Future<void> _onCreateSecureShareEvent(CreateSecureShareEvent event, Emitter<SecureShareState> emit) async {
    emit(CreatingSecureShareState());
    try {
      final secureShare = await _secureShareService.create(data: event.data);
      emit(SecureShareCreatedState(secureShare: secureShare));
    } on Exception catch (e) {
      emit(CreatingSecureShareErrorState(message: e.toString()));
    }
  }

  Future<void> _onUpdateSecureShareEvent(UpdateSecureShareEvent event, Emitter<SecureShareState> emit) async {
    emit(UpdatingSecureShareState());
    try {
      final secureShare = await _secureShareService.update(secureShareId: event.secureShareId, data: event.data);
      emit(SecureShareUpdatedState(secureShare: secureShare));
    } on Exception catch (e) {
      emit(UpdatingSecureShareErrorState(message: e.toString()));
    }
  }

  Future<void> _onDeleteSecureShareEvent(DeleteSecureShareEvent event, Emitter<SecureShareState> emit) async {
    emit(DeletingSecureShareState());
    try {
      await _secureShareService.delete(secureShareId: event.secureShareId);
      emit(SecureShareDeletedState());
    } on Exception catch (e) {
      emit(DeletingSecureShareErrorState(message: e.toString()));
    }
  }
}
