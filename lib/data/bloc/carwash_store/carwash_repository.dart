import 'package:openapi/openapi.dart';

import 'package:openapi/openapi.dart';

import '../../../core/api_client/api_client.dart';

class CarWashRepository {
  CarWashApi get _api => ApiProvider.instance.api.getCarWashApi();

  Future<List<CarWashPrivateRead>> list() async {
    final res = await _api.carWashList();
    return res.data ?? const [];
  }

  Future<CarWashPrivateRead> retrieve(String id) async {
    final res = await _api.carWashRetrieve(carWashId: id);
    final data = res.data;
    if (data == null) throw Exception('Empty response');
    return data;
  }
}