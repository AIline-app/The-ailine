import 'package:openapi/openapi.dart';

class EarningsRepository {
  final EarningsApi _api;

  EarningsRepository(this._api);

  Future<CarWashEarningsRead?> getCarWashEarnings({
    required String carWashId,
    required DateTime dateFrom,
    DateTime? dateTo,
  }) async {
    final response = await _api.carWashEarningsRetrieve(
      carWashId: carWashId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    return response.data;
  }

  Future<WasherEarningsRead?> getWasherEarnings({
    required String carWashId,
    required DateTime dateFrom,
    DateTime? dateTo,
  }) async {
    final response = await _api.carWashWasherEarningsRetrieve(
      carWashId: carWashId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
    return response.data;
  }
}
