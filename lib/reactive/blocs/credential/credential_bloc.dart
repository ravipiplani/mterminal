import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../models/credential.dart';
import '../../../services/credential_service.dart';

part 'credential_event.dart';
part 'credential_state.dart';

class CredentialBloc extends Bloc<CredentialEvent, CredentialState> {
  CredentialBloc() : super(UninitializedState()) {
    on<GetCredentialsEvent>(_onGetCredentialsEvent);
  }

  final _credentialService = CredentialService();

  CredentialState get initialState => UninitializedState();

  Future<void> _onGetCredentialsEvent(GetCredentialsEvent event, Emitter<CredentialState> emit) async {
    emit(RetrieveCredentialsState());
    try {
      final credentials = await _credentialService.get(includeDeleted: event.includeDeleted);
      emit(CredentialsRetrievedState(credentials: credentials));
    } on Exception catch (e) {
      emit(RetrieveCredentialsErrorState(message: e.toString()));
    }
  }
}
