import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_repository.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this._repo) : super(const SignupState.initial());

  final AuthRepository _repo;

  void phoneChanged(String v) => emit(state.copyWith(phone: v, error: null));
  void passwordChanged(String v) => emit(state.copyWith(password: v, error: null));
  void usernameChanged(String v) => emit(state.copyWith(username: v, error: null));

  Future<bool> submit() async {
    if (!state.canSubmit) return false;

    emit(state.copyWith(loading: true, error: null));

    final res = await _repo.signup(
      phone: state.phone.trim(),
      password: state.password,
      username: state.username.trim(),

    );

    if (!res.success) {
      emit(state.copyWith(loading: false, error: res.error ?? 'Signup failed'));
      return false;
    }

    emit(state.copyWith(loading: false));
    return true;
  }
}