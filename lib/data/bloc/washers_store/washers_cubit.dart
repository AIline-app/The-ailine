import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openapi/openapi.dart';
import 'washers_repository.dart';
import 'washers_state.dart';

class WashersCubit extends Cubit<WashersState> {
  final WashersRepository _repo;

  WashersCubit(this._repo) : super(const WashersInitial());

  Future<void> loadWashers(String carWashId) async {
    emit(const WashersLoading());
    try {
      final washers = await _repo.getWashers(carWashId);
      emit(WashersLoaded(washers));
    } catch (e) {
      emit(WashersError(e.toString()));
    }
  }

  Future<void> addWasher(String carWashId, WasherWrite washerWrite) async {
    emit(const WashersLoading());
    try {
      final washer = await _repo.createWasher(carWashId, washerWrite);
      if (washer != null) {
        emit(WasherCreated(washer));
        // Optionally reload the list after adding
        loadWashers(carWashId);
      } else {
        emit(const WashersError('Не удалось добавить мойщика'));
      }
    } catch (e) {
      emit(WashersError(e.toString()));
    }
  }

  Future<void> removeWasher(String carWashId, String userId) async {
    emit(const WashersLoading());
    try {
      await _repo.removeWasher(carWashId, userId);
      loadWashers(carWashId);
    } catch (e) {
      emit(WashersError(e.toString()));
    }
  }
}
