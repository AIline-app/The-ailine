import 'package:openapi/openapi.dart';

sealed class CarTypesState {
  const CarTypesState();
}

class CarTypesInitial extends CarTypesState {
  const CarTypesInitial();
}

class CarTypesLoading extends CarTypesState {
  const CarTypesLoading();
}

class CarTypesLoaded extends CarTypesState {
  const CarTypesLoaded({required this.types, this.selectedIndex = 0});
  final List<CarWashCarTypes> types;
  final int selectedIndex;

  CarTypesLoaded copyWith({List<CarWashCarTypes>? types, int? selectedIndex}) {
    return CarTypesLoaded(
      types: types ?? this.types,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class CarTypesError extends CarTypesState {
  const CarTypesError(this.message);
  final String message;
}
