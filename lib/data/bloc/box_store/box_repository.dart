import 'package:openapi/openapi.dart';

class BoxesRepository {
  BoxesRepository(this._api);

  final BoxesApi _api;

  Future<List<Box>> getBoxes(String carWashId) async {
    final response = await _api.carWashBoxList(carWashId: carWashId);
    return response.data ?? [];
  }

  Future<Box?> getBox(String carWashId, String boxId) async {
    final response = await _api.carWashBoxRetrieve(carWashId: carWashId, boxId: boxId);
    return response.data;
  }
}
