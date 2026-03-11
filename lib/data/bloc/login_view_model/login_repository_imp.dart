import '../../../core/api_client/api_client.dart';
import 'login_repository.dart';
import 'package:openapi/openapi.dart' as gen;
import 'login_repository.dart';
import 'package:openapi/openapi.dart' as gen;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_client/api_client.dart';
import 'login_repository.dart';
import 'package:openapi/openapi.dart' as gen;

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();

  final gen.Openapi _api = ApiProvider.instance.api;

  static const _kSessionTokenKey = 'session_token';

  @override
  Future<LoginResult> verifyPhone({
    required String code,
  }) async {
    try {
      final authApi = _api.getAuthenticationApi();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kSessionTokenKey);

      final response = await authApi.allauthAppPhoneVerify(
        code: code,
        sessionToken: token,
      );

      final status = response.statusCode ?? 0;

      if (status == 200 || status == 401) {
        final newToken = _extractSessionToken(response.data);
        if (newToken != null && newToken.isNotEmpty) {
          await prefs.setString(_kSessionTokenKey, newToken);
          ApiProvider.instance.apiKeyAuth.sessionToken = newToken;
        }
        return LoginResult.success(null);
      }

      return LoginResult.failure('Verify failed: HTTP $status');
    } catch (e) {
      return LoginResult.failure(e.toString());
    }
  }

  @override
  Future<LoginResult> signup({
    required String phone,
    required String password,
    required String username,
  }) async {
    try {
      final authApi = _api.getAuthenticationApi();

      final response = await authApi.allauthAppSignup(
        phone: phone,
        password: password,
        username: username,
        validateStatus: (s) => true,
      );

      final status = response.statusCode ?? 0;
      final token = _extractSessionToken(response.data);

      // Для allauth: 401 с session_token — это success step (verify_phone pending)
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kSessionTokenKey, token);
        ApiProvider.instance.apiKeyAuth.sessionToken = token;
        //print('hello world!');
        return LoginResult.success(null);
      }

      return LoginResult.failure('Signup failed: HTTP $status');
    } catch (e) {
      return LoginResult.failure(e.toString());
    }
  }

  @override
  Future<LoginResult> login({
    required String phone,
    required String password,
  }) async {
    try {
      final authApi = _api.getAuthenticationApi();

      // В allauthAppLogin поле называется login (может быть phone/email/username)
      final response = await authApi.allauthAppLogin(
        login: phone,
        password: password,
      );

      final code = response.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        return LoginResult.failure('Login failed: HTTP $code');
      }

      // 1) достаём токен из response.data
      final token = _extractSessionToken(response.data);

      if (token == null || token.isEmpty) {
        return LoginResult.failure('Login ok, but session_token not found in response');
      }

      final data = response.data as Map<String, dynamic>;

      final userJson = data['data']['user'];
      final user = gen.User.fromJson(userJson);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_token', token);
      ApiProvider.instance.apiKeyAuth.sessionToken = token;

      return LoginResult.success(user);
    } catch (e) {
      return LoginResult.failure(e.toString());
    }
  }

  String? _extractSessionToken(Object? data) {
    if (data is Map) {
      final meta = data['meta'];
      if (meta is Map) {
        final t = meta['session_token'] ?? meta['sessionToken'];
        return t is String ? t : null;
      }
    }
    return null;
  }
}