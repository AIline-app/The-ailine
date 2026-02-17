



import 'package:theIline/core/api_client/api_client.dart';
import 'package:theIline/data/model_car_wash/model_car_wash.dart';

class CarWashRepository {
  final ApiClient apiClient;

  CarWashRepository({required this.apiClient});

  Future<List<CarWashModel>> getAllCarWashes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      CarWashModel(
        id: 1,
        title: "Мойка 'Быстрая'",
        address: "ул. Тестовая, 1",
        distance: 250,
        queueLenght: 2,
        slots: 4,
        rating: 4.7,
        image: 'assets/car_wash_1.jpg',
        latitude: 55.751244,
        longitude: 37.618423,
        inn: '12344566',
        startTime: '12:00',
        endTime: '13:00',
        lastTime: '12:30',
        isValidate: true,
        isActive: false,
      ),
      CarWashModel(
        id: 2,
        title: "Мойка 'Tili'",
        address: "ул. Tast, 12",
        distance: 800,
        queueLenght: 1,
        slots: 5,
        rating: 4.5,
        image: 'assets/car_wash_1.jpg',
        latitude: 55.761244,
        longitude: 37.628423,
        inn: '12344566555',
        startTime: '12:00',
        endTime: '13:00',
        lastTime: '12:30',
        isValidate: true,
        isActive: false,
      )
    ];
  }
}