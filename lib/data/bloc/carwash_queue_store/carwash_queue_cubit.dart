import 'package:flutter_bloc/flutter_bloc.dart';
import 'carwash_queue_repository.dart';
import 'carwash_queue_state.dart';

class CarWashQueueCubit extends Cubit<CarWashQueueState> {
  final CarWashQueueRepository _repo;

  CarWashQueueCubit(this._repo) : super(const CarWashQueueInitial());

  Future<void> loadQueue(String carWashId) async {
    emit(const CarWashQueueLoading());
    try {
      final queue = await _repo.getQueue(carWashId);
      if (queue != null) {
        emit(CarWashQueueLoaded(queue: queue));
      } else {
        emit(const CarWashQueueError('Данные очереди не найдены'));
      }
    } catch (e) {
      emit(CarWashQueueError(e.toString()));
    }
  }
}
