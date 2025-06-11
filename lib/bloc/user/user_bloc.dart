import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_astronacci/api/api_service.dart';
import 'package:mobile_astronacci/models/user.dart';
import 'package:stream_transform/stream_transform.dart';

part 'user_event.dart';
part 'user_state.dart';

const throttleDuration = Duration(milliseconds: 300);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return events.throttle(duration).switchMap(mapper);
  };
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final ApiService _apiService = ApiService();
  String _currentQuery = '';

  UserBloc() : super(UserInitial()) {
    on<FetchUsers>(_onFetchUsers, transformer: throttleDroppable(throttleDuration));
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    int pageToFetch = event.page;
    if (event.query != null && event.query != _currentQuery) {
      _currentQuery = event.query!;
      pageToFetch = 1;
    }

    emit(UserLoading());

    try {
      final response = await _apiService.getUserList(
        page: pageToFetch,
        search: _currentQuery,
      );

      final List<dynamic> userListJson = response.data['data'];
      final users = userListJson.map((json) => User.fromJson(json)).toList();

      emit(UserListLoaded(
        users: users,
        currentPage: response.data['current_page'],
        lastPage: response.data['last_page'],
      ));
    } catch (error) {
      emit(const UserError(error: 'Failed to fetch users.'));
    }
  }
}