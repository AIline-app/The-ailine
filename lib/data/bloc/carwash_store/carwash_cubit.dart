import 'package:flutter_bloc/flutter_bloc.dart';

import 'carwash_repository.dart';
import 'carwash_state.dart';

class CarWashCubit extends Cubit<CarWashState> {
  CarWashCubit(this._repo) : super(const CarWashInitial());

  final CarWashRepository _repo;

  Future<void> load() async {
    emit(const CarWashLoading());
    try {
      final list = await _repo.list();
      print(list);
      emit(CarWashLoaded(items: list));
    } catch (e) {
      emit(CarWashError(e.toString()));
    }
  }

  void select(int index) {
    final s = state;
    if (s is! CarWashLoaded) return;
    if (index < 0 || index >= s.items.length) return;
    emit(s.copyWith(selectedIndex: index));
  }

  void setSort(CarWashSort sort) {
    final s = state;
    if (s is! CarWashLoaded) return;

    final items = [...s.items];

    switch (sort) {
      case CarWashSort.distance:
      // пока нет координат
        items.sort((a, b) => a.name.compareTo(b.name));
        break;

      case CarWashSort.queue:
      // сортировка по количеству боксов
        items.sort((a, b) => a.boxes.length.compareTo(b.boxes.length));
        break;

      case CarWashSort.rating:
      // временно по количеству мойщиков
        items.sort((a, b) => b.washers.length.compareTo(a.washers.length));
        break;

      case CarWashSort.none:
        break;
    }

    final safeIndex =
    items.isEmpty ? 0 : s.selectedIndex.clamp(0, items.length - 1);

    emit(
      s.copyWith(
        items: items,
        sort: sort,
        selectedIndex: safeIndex,
      ),
    );
  }
}