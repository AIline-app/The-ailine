import 'package:dio/dio.dart';
import 'package:gghgggfsfs/core/storage/secure_storage.dart';

class ApiInterceptors extends Interceptor {
  final SecureStorage _storage;

  ApiInterceptors(this._storage);

  @override
  Future<void> onRequest(RequestOptions options,
      RequestInterceptorHandler handler) async {
    final token = await _storage.storage.read(key: SecureStorage.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }


  @override
  Future<void> onError(DioException error,
      ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode == 401) {}
    handler.next(error);
  }
}