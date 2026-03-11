import 'package:openapi/openapi.dart';

sealed class EarningsState {
  const EarningsState();
}

class EarningsInitial extends EarningsState {
  const EarningsInitial();
}

class EarningsLoading extends EarningsState {
  const EarningsLoading();
}

class CarWashEarningsLoaded extends EarningsState {
  final CarWashEarningsRead earnings;
  const CarWashEarningsLoaded(this.earnings);
}

class WasherEarningsLoaded extends EarningsState {
  final WasherEarningsRead earnings;
  const WasherEarningsLoaded(this.earnings);
}

class EarningsError extends EarningsState {
  final String message;
  const EarningsError(this.message);
}
