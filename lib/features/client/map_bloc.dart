import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../data/models/model_car_wash/model_car_wash.dart';
import '../../data/repository/car_wash_repository.dart';
import 'map_event.dart';
import 'map_state.dart';

class CarWashBloc extends Bloc<CarWashEvent, CarWashState> {
  final CarWashRepository repository;

  CarWashBloc(this.repository) : super(CarWashState.initial()) {
    on<LoadCarWashes>(_onLoad);
    on<SelectCarWash>(_onSelect);
    on<SortCarWashes>(_onSort);
  }

  Future<void> _onLoad(LoadCarWashes event, Emitter<CarWashState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final position = await _getCurrentLocation();
      final carWashes = await repository.getAllCarWashes();

      emit(state.copyWith(
        isLoading: false,
        allCarWashes: carWashes,
        visibleCarWashes: carWashes,
        currentPosition: Point(latitude: position.latitude, longitude: position.longitude),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onSelect(SelectCarWash event, Emitter<CarWashState> emit) {
    emit(state.copyWith(selectedIndex: event.selectedIndex));
  }

  void _onSort(SortCarWashes event, Emitter<CarWashState> emit) {
    final current = List<CarWashModel>.from(state.allCarWashes);

    switch (event.criteria) {
      case 'Рейтинг':
        current.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Очередь':
        current.sort((a, b) => a.slots.compareTo(b.slots));
        break;
      case 'Расстояние':
        final user = state.currentPosition;
        if (user != null) {
          current.sort((a, b) {
            final dA = Geolocator.distanceBetween(
              user.latitude, user.longitude, a.latitude ?? 0, a.longitude ?? 0);
            final dB = Geolocator.distanceBetween(
              user.latitude, user.longitude, b.latitude ?? 0, b.longitude ?? 0);
            return dA.compareTo(dB);
          });
        }
        break;
    }

    emit(state.copyWith(visibleCarWashes: current));
  }

  Future<Position> _getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result == LocationPermission.denied || result == LocationPermission.deniedForever) {
        throw Exception('Разрешение на геолокацию не получено');
      }
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}