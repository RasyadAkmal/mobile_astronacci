import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class ApiService {
  final Dio _dio = ApiClient().dio;

  Future<Response> login(String email, String password) async {
    return _dio.post('/login', data: {'email': email, 'password': password});
  }

  Future<Response> register(String name, String email, String password) async {
    return _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Response> logout() async {
    return _dio.post('/logout');
  }

  Future<Response> getAuthenticatedUser() async {
    return _dio.get('/user');
  }

  Future<Response> getUserList({int page = 1, String search = ''}) async {
    return _dio.get('/users', queryParameters: {'page': page, 'search': search});
  }

  Future<Response> getDetailUser(int userId) async {
    return _dio.get('/users/$userId');
  }
  
  Future<Response> updateProfile(String name, {File? avatar}) async {
    FormData formData = FormData.fromMap({
      'name': name,
      if (avatar != null) 'avatar': await MultipartFile.fromFile(avatar.path),
    });
    return _dio.post('/user/update', data: formData);
  }
}