abstract class CarWashEvent {}

class LoadCarWashes extends CarWashEvent {}

class SelectCarWash extends CarWashEvent {
  final int selectedIndex;
  SelectCarWash(this.selectedIndex);
}

class SortCarWashes extends CarWashEvent {
  final String criteria;
  SortCarWashes(this.criteria); // "рейтинг", "очередь", "расстояние"
}
