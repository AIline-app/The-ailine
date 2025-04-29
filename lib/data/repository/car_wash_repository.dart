import '../model_car_wash/model_car_wash.dart';

class CarWashRepository {
  Future<List<CarWashModel>> getAllCarWashes() async {
    await Future.delayed(const Duration(milliseconds: 500)); // симуляция запроса

    return [
      CarWashModel(
        id: 1,
        name: 'Автомойка 777',
        latitude: 51.132,
        longitude: 71.43,
        queueLength: 12,
        boxCount: 4,
        rating: 4.8,
        distance: 530,
      ),
      CarWashModel(
        id: 2,
        name: 'Автомойка Lux',
        latitude: 51.131,
        longitude: 71.432,
        queueLength: 5,
        boxCount: 3,
        rating: 4.2,
        distance: 510,
      ),
      CarWashModel(
        id: 3,
        name: 'Авто Spa',
        latitude: 51.130,
        longitude: 71.431,
        queueLength: 2,
        boxCount: 2,
        rating: 3.9,
        distance: 920,
      ),
    ];
  }
}