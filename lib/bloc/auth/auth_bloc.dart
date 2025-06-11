import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_astronacci/api/api_service.dart';
import 'package:mobile_astronacci/models/user.dart';
import 'package:mobile_astronacci/utils/token_manager.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService = ApiService();

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final token = await TokenManager.getToken();
      if (token != null && token.isNotEmpty) {
        final response = await _apiService.getAuthenticatedUser();
        final user = User.fromJson(response.data);
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.login(event.email, event.password);
      final user = User.fromJson(response.data['user']);
      final token = response.data['access_token'];
      await TokenManager.saveToken(token);
      emit(Authenticated(user: user));
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Login failed. Please try again.';
      emit(AuthFailure(error: errorMessage));
      emit(const Unauthenticated());
    } catch (e) {
      emit(const AuthFailure(error: 'An unexpected error occurred.'));
      emit(const Unauthenticated());
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _apiService.register(event.name, event.email, event.password);
      emit(const Unauthenticated(
          message: 'Registration successful. Please login.'));
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ??
          'Registration failed. Please try again.';
      emit(AuthFailure(error: errorMessage));
      emit(const Unauthenticated());
    } catch (e) {
      emit(const AuthFailure(error: 'An unexpected error occurred.'));
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _apiService.logout();
    } finally {
      await TokenManager.deleteToken();
      emit(const Unauthenticated(message: 'You have been logged out.'));
    }
  }
}