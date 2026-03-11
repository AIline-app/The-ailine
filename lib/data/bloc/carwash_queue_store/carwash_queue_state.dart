import 'package:openapi/openapi.dart';

sealed class CarWashQueueState {
  const CarWashQueueState();
}

class CarWashQueueInitial extends CarWashQueueState {
  const CarWashQueueInitial();
}

class CarWashQueueLoading extends CarWashQueueState {
  const CarWashQueueLoading();
}

class CarWashQueueLoaded extends CarWashQueueState {
  const CarWashQueueLoaded({required this.queue});
  final CarWashQueue queue;
}

class CarWashQueueError extends CarWashQueueState {
  const CarWashQueueError(this.message);
  final String message;
}
