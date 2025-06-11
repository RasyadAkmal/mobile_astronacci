part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class FetchUsers extends UserEvent {
  final int page;
  final String? query;

  const FetchUsers({this.page = 1, this.query});

  @override
  List<Object?> get props => [page, query];
}