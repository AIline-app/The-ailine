import 'package:yandex_mapkit/yandex_mapkit.dart';

abstract class CarWashEvent {}

class LoadCarWashes extends CarWashEvent {}

class ChangeVisibleArea extends CarWashEvent {
  final BoundingBox bounds;
  ChangeVisibleArea(this.bounds);
}

class SelectCarWash extends CarWashEvent {
  final int selectedIndex;
  SelectCarWash(this.selectedIndex);
}
