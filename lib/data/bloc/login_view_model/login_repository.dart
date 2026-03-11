import 'package:openapi/openapi.dart' as gen;

abstract class AuthRepository {
  Future<LoginResult> login({required String phone, required String password});
  Future<LoginResult> signup({
    required String phone,
    required String password,
    required String username,
  });
  Future<LoginResult> verifyPhone({
    required String code,
  });
}
class LoginResult {
  final bool success;
  final String? error;
  final gen.User? user;

  LoginResult.success(this.user)
      : success = true,
        error = null;

  LoginResult.failure(this.error)
      : success = false,
        user = null;
}