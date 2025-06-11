import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_astronacci/api/api_service.dart';
import 'package:mobile_astronacci/models/user.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService _apiService = ApiService();

  ProfileBloc() : super(ProfileInitial()) {
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onUpdateProfileRequested(
      UpdateProfileRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileUpdateLoading());
    try {
      final response =
          await _apiService.updateProfile(event.name, avatar: event.avatar);
      final updatedUser = User.fromJson(response.data['user']);
      emit(ProfileUpdateSuccess(user: updatedUser));
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Update failed. Please try again.';
      emit(ProfileUpdateFailure(error: errorMessage));
    } catch (e) {
      emit(const ProfileUpdateFailure(error: 'An unexpected error occurred.'));
    }
  }
}