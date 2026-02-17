import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:theIline/data/model_car_wash/model_car_wash.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../data/repository/car_wash_repository.dart';
import 'map_event.dart';
import 'map_state.dart';

class CarWashBloc extends Bloc<CarWashEvent, CarWashState> {
  final CarWashRepository repository;

  CarWashBloc(this.repository) : super(CarWashState.initial()) {
    on<LoadCarWashes>(_onLoad);
    on<ChangeVisibleArea>(_onAreaChanged);
    on<SelectCarWash>(_onSelect);
  }

  Future<void> _onLoad(LoadCarWashes event, Emitter<CarWashState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final location = await _getUserLocation();
      final carWashes = await _fetchCarWashes();

      emit(
        state.copyWith(
          isLoading: false,
          visibleCarWashes: carWashes,
          allCarWashes: carWashes,
          currentPosition: location,
        ),
      );
    } on LocationPermissionDeniedException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } on LocationServiceException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (e, stackTrace) {
      log('Failed to load car washes', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Не удалось загрузить список автомоек',
        ),
      );
    }
  }

  Future<void> _onAreaChanged(
    ChangeVisibleArea event,
    Emitter<CarWashState> emit,
  ) async {
    // Пока пустая обработка события изменения области видимости
    // Можно потом добавить фильтрацию автомоек по видимой области
  }

  Future<void> _onSelect(
    SelectCarWash event,
    Emitter<CarWashState> emit,
  ) async {
    emit(state.copyWith(selectedIndex: event.selectedIndex));
  }

  Future<Point> _getUserLocation() async {
    try {
      final permission = await _checkAndRequestLocationPermission();
      if (!permission.isGranted) {
        throw LocationPermissionDeniedException(
          permission.isPermanentlyDenied
              ? 'Доступ к геолокации запрещён навсегда. Пожалуйста, включите его в настройках.'
              : 'Доступ к геолокации запрещён.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      return Point(latitude: position.latitude, longitude: position.longitude);
    } on PlatformException catch (e) {
      throw LocationServiceException('Ошибка сервиса геолокации: ${e.message}');
    } on TimeoutException {
      throw LocationServiceException('Таймаут получения местоположения');
    }
  }

  Future<LocationPermissionStatus> _checkAndRequestLocationPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return LocationPermissionStatus(
      isGranted:
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse,
      isPermanentlyDenied: permission == LocationPermission.deniedForever,
    );
  }

  Future<List<CarWashModel>> _fetchCarWashes() async {
    try {
      return await repository.getAllCarWashes().timeout(
        const Duration(seconds: 15),
      );
    } on TimeoutException {
      throw DataFetchingException('Таймаут загрузки данных');
    } on SocketException {
      throw DataFetchingException('Нет подключения к интернету');
    }
  }
}

// Кастомные исключения для более точной обработки ошибок
class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);
}

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);
}

class DataFetchingException implements Exception {
  final String message;
  DataFetchingException(this.message);
}

// Вспомогательная структура для статуса разрешений
class LocationPermissionStatus {
  final bool isGranted;
  final bool isPermanentlyDenied;

  LocationPermissionStatus({
    required this.isGranted,
    required this.isPermanentlyDenied,
  });
}
