import 'package:flutter_bloc/flutter_bloc.dart';
import 'services_repository.dart';
import 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServicesRepository _repo;

  ServicesCubit(this._repo) : super(const ServicesInitial());

  Future<void> loadServices(String carWashId) async {
    emit(const ServicesLoading());
    try {
      final services = await _repo.getServices(carWashId);
      emit(ServicesLoaded(services: services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  void toggleService(String serviceId) {
    final s = state;
    if (s is ServicesLoaded) {
      final newSelectedIds = Set<String>.from(s.selectedServiceIds);
      if (newSelectedIds.contains(serviceId)) {
        newSelectedIds.remove(serviceId);
      } else {
        newSelectedIds.add(serviceId);
      }
      emit(s.copyWith(selectedServiceIds: newSelectedIds));
    }
  }
}
