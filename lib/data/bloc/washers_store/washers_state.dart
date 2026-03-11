import 'package:openapi/openapi.dart';

sealed class WashersState {
  const WashersState();
}

class WashersInitial extends WashersState {
  const WashersInitial();
}

class WashersLoading extends WashersState {
  const WashersLoading();
}

class WashersLoaded extends WashersState {
  final List<User> washers;
  const WashersLoaded(this.washers);
}

class WasherCreated extends WashersState {
  final User washer;
  const WasherCreated(this.washer);
}

class WashersError extends WashersState {
  final String message;
  const WashersError(this.message);
}
