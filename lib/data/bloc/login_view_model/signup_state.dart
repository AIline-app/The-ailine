import 'package:equatable/equatable.dart';

class SignupState {
  final String phone;
  final String password;
  final String username;
  final bool loading;
  final String? error;

  const SignupState({
    required this.phone,
    required this.password,
    required this.username,
    required this.loading,
    required this.error,
  });

  const SignupState.initial()
      : phone = '',
        password = '',
        username = '',
        loading = false,
        error = null;

  bool get canSubmit =>
      !loading &&
          phone.trim().isNotEmpty &&
          password.isNotEmpty &&
          username.trim().isNotEmpty;

  SignupState copyWith({
    String? phone,
    String? password,
    String? username,
    bool? loading,
    String? error,
  }) {
    return SignupState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      username: username ?? this.username,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}