import 'package:openapi/openapi.dart';

import '../../model_car_wash/model_car_wash.dart';

sealed class CarWashState {
  const CarWashState();
}

class CarWashInitial extends CarWashState {
  const CarWashInitial();
}

class CarWashLoading extends CarWashState {
  const CarWashLoading();
}

class CarWashLoaded extends CarWashState {
  const CarWashLoaded({
    required this.items,
    this.selectedIndex = 0,
    this.sort = CarWashSort.none,
  });

  final List<CarWashPrivateRead> items;
  final int selectedIndex;
  final CarWashSort sort;

  CarWashLoaded copyWith({
    List<CarWashPrivateRead>? items,
    int? selectedIndex,
    CarWashSort? sort,
  }) => CarWashLoaded(
    items: items ?? this.items,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    sort: sort ?? this.sort,
  );
}

class CarWashError extends CarWashState {
  const CarWashError(this.message);
  final String message;
}

enum CarWashSort { none, distance, queue, rating }