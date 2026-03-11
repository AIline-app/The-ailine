import 'package:flutter_bloc/flutter_bloc.dart';
import 'earnings_repository.dart';
import 'earnings_state.dart';

class EarningsCubit extends Cubit<EarningsState> {
  final EarningsRepository _repo;

  EarningsCubit(this._repo) : super(const EarningsInitial());

  Future<void> loadCarWashEarnings({
    required String carWashId,
    required DateTime dateFrom,
    DateTime? dateTo,
  }) async {
    emit(const EarningsLoading());
    try {
      final earnings = await _repo.getCarWashEarnings(
        carWashId: carWashId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      if (earnings != null) {
        emit(CarWashEarningsLoaded(earnings));
      } else {
        emit(const EarningsError('Данные о доходах не найдены'));
      }
    } catch (e) {
      emit(EarningsError(e.toString()));
    }
  }

  Future<void> loadWasherEarnings({
    required String carWashId,
    required DateTime dateFrom,
    DateTime? dateTo,
  }) async {
    emit(const EarningsLoading());
    try {
      final earnings = await _repo.getWasherEarnings(
        carWashId: carWashId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      if (earnings != null) {
        emit(WasherEarningsLoaded(earnings));
      } else {
        emit(const EarningsError('Данные о заработке мойщиков не найдены'));
      }
    } catch (e) {
      emit(EarningsError(e.toString()));
    }
  }
}
