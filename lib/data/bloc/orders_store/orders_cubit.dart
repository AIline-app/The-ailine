import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openapi/openapi.dart';
import 'orders_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _repo;

  OrdersCubit(this._repo) : super(const OrdersInitial());

  Future<void> createOrder(String carWashId, OrdersCreate ordersCreate) async {
    emit(const OrdersLoading());
    try {
      final order = await _repo.createOrder(carWashId, ordersCreate);
      if (order != null) {
        emit(OrderCreated(order: order));
      } else {
        emit(const OrdersError('Не удалось создать заказ'));
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> fetchOrders(String carWashId) async {
    emit(const OrdersLoading());
    try {
      final orders = await _repo.listOrders(carWashId);
      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
