import 'package:openapi/openapi.dart';

class CarWashQueueRepository {
  final CarWashApi _api;

  CarWashQueueRepository(this._api);

  Future<CarWashQueue?> getQueue(String carWashId) async {
    final response = await _api.carWashQueueRetrieve(carWashId: carWashId);
    return response.data;
  }
}
