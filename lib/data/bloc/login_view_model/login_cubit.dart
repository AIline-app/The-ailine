import 'package:flutter_bloc/flutter_bloc.dart';
import '../user_store/user_cubit.dart';
import './login_state.dart';
import './login_repository.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repo, this._userCubit)
      : super(const LoginState.initial());

  final AuthRepository _repo;
  final UserCubit _userCubit;

  void phoneChanged(String v) => emit(state.copyWith(phone: v, error: null));
  void passwordChanged(String v) => emit(state.copyWith(password: v, error: null));

  Future<void> submit() async {
    if (!state.canSubmit) return;

    emit(state.copyWith(loading: true, error: null));

    try {
      final result = await _repo.login(
        phone: state.phone.trim(),
        password: state.password,
      );

      if (result.success) {
        final user = result.user;

        if (user != null) {
          _userCubit.setUser(user);
        }

        emit(state.copyWith(
          loading: false,
          success: true,
        ));
      } else {
        emit(state.copyWith(
          loading: false,
          error: result.error,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }
}