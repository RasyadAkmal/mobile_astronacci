part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserListLoaded extends UserState {
  final List<User> users;
  final int currentPage;
  final int lastPage;

  const UserListLoaded({
    required this.users,
    required this.currentPage,
    required this.lastPage,
  });

  @override
  List<Object> get props => [users, currentPage, lastPage];
}

class UserError extends UserState {
  final String error;

  const UserError({required this.error});

  @override
  List<Object> get props => [error];
}