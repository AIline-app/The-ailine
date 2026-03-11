
import 'package:yandex_mapkit/yandex_mapkit.dart';

Point? parseLocation(String? location) {
  if (location == null || location.isEmpty) return null;

  try {
    if (location.contains(',')) {
      final parts = location.split(',');
      final lat = double.parse(parts[0]);
      final lon = double.parse(parts[1]);
      return Point(latitude: lat, longitude: lon);
    }

    // формат: "POINT(71.4704 51.1605)"
    if (location.contains('POINT')) {
      final cleaned = location
          .replaceAll('POINT(', '')
          .replaceAll(')', '')
          .trim()
          .split(' ');

      final lon = double.parse(cleaned[0]);
      final lat = double.parse(cleaned[1]);

      return Point(latitude: lat, longitude: lon);
    }
  } catch (_) {}

  return null;
}