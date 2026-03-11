import 'package:flutter_bloc/flutter_bloc.dart';
import 'car_types_repository.dart';
import 'car_types_state.dart';

class CarTypesCubit extends Cubit<CarTypesState> {
  final CarTypesRepository _repo;

  CarTypesCubit(this._repo) : super(const CarTypesInitial());

  Future<void> loadCarTypes(String carWashId) async {
    emit(const CarTypesLoading());
    try {
      final types = await _repo.getCarTypes(carWashId);
      emit(CarTypesLoaded(types: types));
    } catch (e) {
      emit(CarTypesError(e.toString()));
    }
  }

  void selectType(int index) {
    final s = state;
    if (s is CarTypesLoaded) {
      emit(s.copyWith(selectedIndex: index));
    }
  }
}
