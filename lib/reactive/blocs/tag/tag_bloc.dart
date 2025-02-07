import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../models/tag.dart';
import '../../../services/tag_service.dart';

part 'tag_event.dart';
part 'tag_state.dart';

class TagBloc extends Bloc<TagEvent, TagState> {
  TagBloc() : super(UninitializedState()) {
    on<GetTagsEvent>(_onGetTagsEvent);
  }

  final _tagService = TagService();

  TagState get initialState => UninitializedState();

  Future<void> _onGetTagsEvent(GetTagsEvent event, Emitter<TagState> emit) async {
    emit(RetrieveTagsState());
    try {
      final tags = await _tagService.get(includeDeleted: event.includeDeleted, onRemote: event.onRemote);
      emit(TagsRetrievedState(tags: tags));
    } on Exception catch (e) {
      emit(RetrieveTagsErrorState(message: e.toString()));
    }
  }
}
