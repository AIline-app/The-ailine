import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openapi/openapi.dart';

class ApiProvider {
  ApiProvider._();

  static final ApiProvider instance = ApiProvider._();

  late final Dio dio;
  late final ApiKeyAuthInterceptor apiKeyAuth; // <-- доступен снаружи
  late final Openapi api;

  static const _kSessionTokenKey = 'session_token';

  Future<void> init() async {
    dio = Dio(BaseOptions(
      baseUrl: 'http://90.156.230.67:8000',
      contentType: 'application/json',
    ));

    // cookies можно оставить (не мешает)
    final jar = CookieJar();
    dio.interceptors.add(CookieManager(jar));

    // наш interceptor (тот, где ты добавил sessionToken)
    apiKeyAuth = ApiKeyAuthInterceptor();
    dio.interceptors.add(apiKeyAuth);

    // восстановить токен при старте
    final prefs = await SharedPreferences.getInstance();
    apiKeyAuth.sessionToken = prefs.getString(_kSessionTokenKey);

    api = Openapi(dio: dio);
  }
}