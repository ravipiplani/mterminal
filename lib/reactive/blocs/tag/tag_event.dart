part of 'tag_bloc.dart';

abstract class TagEvent {}

class UninitializedEvent extends TagEvent {}

class GetTagsEvent extends TagEvent {
  GetTagsEvent({this.includeDeleted = false, this.onRemote = false});

  final bool includeDeleted;
  final bool onRemote;

  List<Object> get props => [includeDeleted, onRemote];
}
