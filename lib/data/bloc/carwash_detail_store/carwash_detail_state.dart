import 'package:openapi/openapi.dart';

sealed class CarWashDetailState {
  const CarWashDetailState();
}

class CarWashDetailInitial extends CarWashDetailState {
  const CarWashDetailInitial();
}

class CarWashDetailLoading extends CarWashDetailState {
  const CarWashDetailLoading();
}

class CarWashDetailLoaded extends CarWashDetailState {
  const CarWashDetailLoaded(this.item);
  final CarWashPrivateRead item;
}

class CarWashDetailError extends CarWashDetailState {
  const CarWashDetailError(this.message);
  final String message;
}