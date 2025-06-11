part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileUpdateLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final User user;

  const ProfileUpdateSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class ProfileUpdateFailure extends ProfileState {
  final String error;

  const ProfileUpdateFailure({required this.error});

  @override
  List<Object> get props => [error];
}