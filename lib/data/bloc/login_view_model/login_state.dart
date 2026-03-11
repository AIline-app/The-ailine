import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String phone;
  final String password;
  final bool loading;
  final String? error;
  final bool success;

  const LoginState({
    required this.phone,
    required this.password,
    required this.loading,
    required this.error,
    required this.success,
  });
  bool get isPhoneValid =>
      phone.replaceAll(RegExp(r'\D'), '').length == 11;
  const LoginState.initial()
      : phone = '',
        password = '',
        loading = false,
        error = null,
        success = false;
  bool get canSubmit => phone.trim().isNotEmpty && password.isNotEmpty && !loading;

  LoginState copyWith({
    String? phone,
    String? password,
    bool? loading,
    String? error,
    bool? success,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error, // null очищает
    );
  }

  @override
  List<Object?> get props => [phone, password, loading, error, success];
}