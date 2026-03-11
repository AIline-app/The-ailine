
import 'package:openapi/openapi.dart';

class UserState {
  final User? user;

  const UserState({this.user});

  UserState copyWith({User? user}) {
    return UserState(user: user ?? this.user);
  }
}