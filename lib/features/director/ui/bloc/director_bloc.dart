import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'director_event.dart';
import 'director_state.dart';

class DirectorBloc extends Bloc<DirectorEvent, DirectorState> {
  DirectorBloc() : super(DirectorInitial()) {
    on<LoadDirectorData>(_onLoadDirectorData);
    on<UpdateCarWashName>(_onUpdateCarWashName);
    on<UpdateCarWashTIN>(_onUpdateCarWashTIN);
    on<UpdateCarWashAddress>(_onUpdateCarWashAddress);
    on<UpdateWorkingHours>(_onUpdateWorkingHours);
    on<UpdateSlotsCount>(_onUpdateSlotsCount);
    on<UpdatePercentage>(_onUpdatePercentage);
    on<AddService>(_onAddService);
    on<UpdateService>(_onUpdateService);
    on<DeleteService>(_onDeleteService);
    on<ChangeCarType>(_onChangeCarType);
    on<SubmitCarWashData>(_onSubmitCarWashData);
    on<Clicked>(_onClicked);
  }

  FutureOr<void> _onLoadDirectorData(
    LoadDirectorData event,
    Emitter<DirectorState> emit,
  ) async {
    emit(DirectorLoading());
    try {
      // Simulate loading data
      await Future.delayed(Duration(milliseconds: 500));
      
      final carWash = CarWashModel();
      final services = <ServiceModel>[
        ServiceModel(
          title: 'Стандарт',
          subtitle: 'Пена, вода, сушка',
          minutes: '30 мин',
          price: '500р',
        ),
      ];
      
      emit(DirectorLoaded(
        carWash: carWash,
        services: services,
        selectedCarType: 'седан',
      ));
    } catch (e) {
      emit(DirectorError('Ошибка загрузки данных: ${e.toString()}'));
    }
  }

  FutureOr<void> _onUpdateCarWashName(
    UpdateCarWashName event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      emit(currentState.copyWith(
        carWash: currentState.carWash.copyWith(name: event.name),
      ));
    }
  }

  FutureOr<void> _onUpdateCarWashTIN(
    UpdateCarWashTIN event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      emit(currentState.copyWith(
        carWash: currentState.carWash.copyWith(tin: event.tin),
      ));
    }
  }

  FutureOr<void> _onUpdateCarWashAddress(
    UpdateCarWashAddress event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      emit(currentState.copyWith(
        carWash: currentState.carWash.copyWith(address: event.address),
      ));
    }
  }

  FutureOr<void> _onUpdateWorkingHours(
    UpdateWorkingHours event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      emit(currentState.copyWith(
        carWash: currentState.carWash.copyWith(
          startTime: event.startTime,
          endTime: event.endTime,
        ),
      ));
    }
  }

  FutureOr<void> _onUpdateSlotsCount(
    UpdateSlotsCount event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      emit(currentState.copyWith(
        carWash: currentState.carWash.copyWith(slotsCount: event.slotsCount),
      ));
    }
  }

  FutureOr<void> _onUpdatePercentage(
    UpdatePercentage event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      emit(currentState.copyWith(
        carWash: currentState.carWash.copyWith(percentage: event.percentage),
      ));
    }
  }

  FutureOr<void> _onAddService(
    AddService event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      final newServices = List<ServiceModel>.from(currentState.services)
        ..add(event.service);
      
      emit(currentState.copyWith(services: newServices));
    }
  }

  FutureOr<void> _onUpdateService(
    UpdateService event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      final newServices = List<ServiceModel>.from(currentState.services);
      
      if (event.index >= 0 && event.index < newServices.length) {
        newServices[event.index] = event.service;
        emit(currentState.copyWith(services: newServices));
      }
    }
  }

  FutureOr<void> _onDeleteService(
    DeleteService event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      final newServices = List<ServiceModel>.from(currentState.services);
      
      if (event.index >= 0 && event.index < newServices.length) {
        newServices.removeAt(event.index);
        emit(currentState.copyWith(services: newServices));
      }
    }
  }

  FutureOr<void> _onChangeCarType(
    ChangeCarType event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      emit(currentState.copyWith(selectedCarType: event.carType));
    }
  }

  FutureOr<void> _onSubmitCarWashData(
    SubmitCarWashData event,
    Emitter<DirectorState> emit,
  ) async {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      
      emit(DirectorLoading());
      
      try {
        // Simulate API call
        await Future.delayed(Duration(seconds: 1));
        
        if (!currentState.carWash.isValid) {
          throw Exception('Не все поля заполнены');
        }
        
        // Here you would typically save to API
        emit(DirectorSuccess('Данные автомойки успешно сохранены'));
        
        // Return to loaded state
        emit(currentState);
      } catch (e) {
        emit(DirectorError('Ошибка сохранения: ${e.toString()}'));
        emit(currentState);
      }
    }
  }

  FutureOr<void> _onClicked(
    Clicked event,
    Emitter<DirectorState> emit,
  ) {
    if (state is DirectorLoaded) {
      final currentState = state as DirectorLoaded;
      emit(currentState.copyWith(isClicked: true));
    } else {
      emit(DirectorLoaded(
        carWash: CarWashModel(),
        services: [],
        selectedCarType: 'седан',
        isClicked: true,
      ));
    }
  }
}

// void _onSaveCarWashData(SaveCarWashData event, Emitter<DirectorState> emit) async {
//   try {
//     emit(DirectorSaving());
    
//     // Здесь вызываете API для сохранения данных
//     await _repository.saveCarWashData(/* текущие данные */);
    
//     emit(DirectorSuccess('Данные успешно сохранены'));
//   } catch (e) {
//     emit(DirectorError('Ошибка при сохранении данных: $e'));
//   }
// }