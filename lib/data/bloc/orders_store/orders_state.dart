import 'package:openapi/openapi.dart';

sealed class OrdersState {
  const OrdersState();
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrderCreated extends OrdersState {
  const OrderCreated({required this.order});
  final OrdersRead order;
}

class OrdersLoaded extends OrdersState {
  const OrdersLoaded({required this.orders});
  final List<OrdersRead> orders;
}

class OrdersError extends OrdersState {
  const OrdersError(this.message);
  final String message;
}
