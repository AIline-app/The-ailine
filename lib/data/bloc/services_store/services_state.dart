import 'package:openapi/openapi.dart';

sealed class ServicesState {
  const ServicesState();
}

class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

class ServicesLoaded extends ServicesState {
  const ServicesLoaded({required this.services, this.selectedServiceIds = const {}});
  final List<ServicesRead> services;
  final Set<String> selectedServiceIds;

  ServicesLoaded copyWith({List<ServicesRead>? services, Set<String>? selectedServiceIds}) {
    return ServicesLoaded(
      services: services ?? this.services,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
    );
  }
}

class ServicesError extends ServicesState {
  const ServicesError(this.message);
  final String message;
}
