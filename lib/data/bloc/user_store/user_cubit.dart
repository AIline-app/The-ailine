import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openapi/openapi.dart';
import 'package:theIline/data/bloc/user_store/user_state.dart';


class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState());

  void setUser(User user) {
    emit(state.copyWith(user: user));
  }

  void clear() {
    emit(const UserState());
  }
}