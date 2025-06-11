part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class UpdateProfileRequested extends ProfileEvent {
  final String name;
  final File? avatar;

  const UpdateProfileRequested({required this.name, this.avatar});

  @override
  List<Object?> get props => [name, avatar];
}