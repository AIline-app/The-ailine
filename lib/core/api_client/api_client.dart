import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient() : dio = Dio() {
    dio.options = BaseOptions(
      baseUrl: 'https://future-api-url.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) => handler.next(options),
      onError: (error, handler) => handler.next(error),
    ));
  }

  Future<List<Map<String, dynamic>>> getCarWashes() async {
    return [];
  }
}