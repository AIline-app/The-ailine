import 'package:flutter_bloc/flutter_bloc.dart';

import '../carwash_store/carwash_repository.dart';
import 'carwash_detail_state.dart';

class CarWashDetailCubit extends Cubit<CarWashDetailState> {
  CarWashDetailCubit(this._repo) : super(const CarWashDetailInitial());

  final CarWashRepository _repo;

  Future<void> load(String id) async {
    emit(const CarWashDetailLoading());
    try {
      final item = await _repo.retrieve(id);
      emit(CarWashDetailLoaded(item));
    } catch (e) {
      emit(CarWashDetailError(e.toString()));
    }
  }
}