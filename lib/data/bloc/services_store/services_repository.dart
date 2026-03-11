import 'package:openapi/openapi.dart';

class ServicesRepository {
  final ServicesApi _api;

  ServicesRepository(this._api);

  Future<List<ServicesRead>> getServices(String carWashId) async {
    final response = await _api.carWashServiceList(carWashId: carWashId);
    return response.data ?? [];
  }
}
