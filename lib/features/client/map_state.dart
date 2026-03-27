import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../data/model_car_wash/model_car_wash.dart';

class CarWashState {
  final bool isLoading;
  final List<CarWashModel> allCarWashes;
  final List<CarWashModel> visibleCarWashes;
  final int selectedIndex;
  final Point? currentPosition;

  CarWashState({
    required this.isLoading,
    required this.allCarWashes,
    required this.visibleCarWashes,
    required this.selectedIndex,
    required this.currentPosition,
  });

  factory CarWashState.initial() => CarWashState(
    isLoading: false,
    allCarWashes: [],
    visibleCarWashes: [],
    selectedIndex: 0,
    currentPosition: null,
  );

  CarWashState copyWith({
    bool? isLoading,
    List<CarWashModel>? allCarWashes,
    List<CarWashModel>? visibleCarWashes,
    int? selectedIndex,
    Point? currentPosition,
    String? error,
  }) {
    return CarWashState(
      isLoading: isLoading ?? this.isLoading,
      allCarWashes: allCarWashes ?? this.allCarWashes,
      visibleCarWashes: visibleCarWashes ?? this.visibleCarWashes,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}
