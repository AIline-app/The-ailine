import 'package:openapi/openapi.dart';

class CarTypesRepository {
  final CarTypesApi _api;

  CarTypesRepository(this._api);

  Future<List<CarWashCarTypes>> getCarTypes(String carWashId) async {
    final response = await _api.carWashCarTypeList(carWashId: carWashId);
    return response.data ?? [];
  }
}
