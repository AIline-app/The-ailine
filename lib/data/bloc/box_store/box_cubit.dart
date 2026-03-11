import 'package:flutter_bloc/flutter_bloc.dart';

import 'box_repository.dart';
import 'box_state.dart';

class BoxesCubit extends Cubit<BoxesState> {
  BoxesCubit(this._repo) : super(const BoxesState.initial());

  final BoxesRepository _repo;

  Future<void> loadBoxes(String carWashId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final boxes = await _repo.getBoxes(carWashId);

      emit(state.copyWith(
        loading: false,
        boxes: boxes,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadBox(String carWashId, String boxId) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final box = await _repo.getBox(carWashId, boxId);

      emit(state.copyWith(
        loading: false,
        selectedBox: box,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
    }
  }
}
