import 'package:openapi/openapi.dart';

class OrdersRepository {
  final OrdersApi _api;

  OrdersRepository(this._api);

  Future<OrdersRead?> createOrder(String carWashId, OrdersCreate ordersCreate) async {
    final response = await _api.carWashOrderCreate(
      carWashId: carWashId,
      ordersCreate: ordersCreate,
    );
    return response.data;
  }

  Future<List<OrdersRead>> listOrders(String carWashId) async {
    final response = await _api.carWashOrderList(carWashId: carWashId);
    return response.data ?? [];
  }

  Future<OrdersRead?> retrieveOrder(String carWashId, String orderId) async {
    final response = await _api.carWashOrderRetrieve(carWashId: carWashId, orderId: orderId);
    return response.data;
  }

  Future<void> cancelOrder(String carWashId, String orderId) async {
    await _api.carWashOrderDestroy(carWashId: carWashId, orderId: orderId);
  }
}
