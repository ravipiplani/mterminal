part of 'tag_bloc.dart';

abstract class TagState {
  TagState();
}

class UninitializedState extends TagState {}

//Retrieving Tags
class RetrieveTagsState extends TagState {}

class TagsRetrievedState extends TagState {
  TagsRetrievedState({required this.tags});

  final List<Tag> tags;

  List<Object> get props => [tags];
}

class RetrieveTagsErrorState extends TagState {
  RetrieveTagsErrorState({required this.message});

  final String message;

  List<Object> get props => [message];
}
