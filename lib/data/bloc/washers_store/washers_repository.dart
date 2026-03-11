import 'package:openapi/openapi.dart';

class WashersRepository {
  final WashersApi _api;

  WashersRepository(this._api);

  Future<List<User>> getWashers(String carWashId) async {
    final response = await _api.carWashWasherList(carWashId: carWashId);
    return response.data ?? [];
  }

  Future<User?> createWasher(String carWashId, WasherWrite washerWrite) async {
    final response = await _api.carWashWasherCreate(
      carWashId: carWashId,
      washerWrite: washerWrite,
    );
    return response.data;
  }

  Future<void> removeWasher(String carWashId, String userId) async {
    await _api.carWashWasherDestroy(carWashId: carWashId, userId: userId);
  }
}
