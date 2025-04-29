import 'package:yandex_mapkit/yandex_mapkit.dart';

class LocationService {
  Future<Point> getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1)); // Симуляция задержки
    return Point(latitude: 51.169392, longitude: 71.449074); // Мок-координаты
  }
}
