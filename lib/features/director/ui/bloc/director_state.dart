import 'director_event.dart';

abstract class DirectorState {}

class DirectorInitial extends DirectorState {}

class DirectorLoading extends DirectorState {}

class DirectorLoaded extends DirectorState {
  final CarWashModel carWash;
  final List<ServiceModel> services;
  final String selectedCarType;
  final bool isClicked;

  DirectorLoaded({
    required this.carWash,
    required this.services,
    required this.selectedCarType,
    this.isClicked = false,
  });

  DirectorLoaded copyWith({
    CarWashModel? carWash,
    List<ServiceModel>? services,
    String? selectedCarType,
    bool? isClicked,
  }) {
    return DirectorLoaded(
      carWash: carWash ?? this.carWash,
      services: services ?? this.services,
      selectedCarType: selectedCarType ?? this.selectedCarType,
      isClicked: isClicked ?? this.isClicked,
    );
  }
}

class DirectorError extends DirectorState {
  final String message;
  DirectorError(this.message);
}

class DirectorSuccess extends DirectorState {
  final String message;
  DirectorSuccess(this.message);
}

class CarWashModel {
  final String name;
  final String tin;
  final String address;
  final String startTime;
  final String endTime;
  final int slotsCount;
  final double percentage;

  CarWashModel({
    this.name = '',
    this.tin = '',
    this.address = '',
    this.startTime = '',
    this.endTime = '',
    this.slotsCount = 0,
    this.percentage = 0.0,
  });

  bool get isValid {
    return name.isNotEmpty &&
        tin.isNotEmpty &&
        address.isNotEmpty &&
        startTime.isNotEmpty &&
        endTime.isNotEmpty &&
        slotsCount > 0 &&
        percentage > 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tin': tin,
      'address': address,
      'startTime': startTime,
      'endTime': endTime,
      'slotsCount': slotsCount,
      'percentage': percentage,
    };
  }

  factory CarWashModel.fromJson(Map<String, dynamic> json) {
    return CarWashModel(
      name: json['name'] ?? '',
      tin: json['tin'] ?? '',
      address: json['address'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      slotsCount: json['slotsCount'] ?? 0,
      percentage: json['percentage'] ?? 0.0,
    );
  }

  CarWashModel copyWith({
    String? name,
    String? tin,
    String? address,
    String? startTime,
    String? endTime,
    int? slotsCount,
    double? percentage,
  }) {
    return CarWashModel(
      name: name ?? this.name,
      tin: tin ?? this.tin,
      address: address ?? this.address,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotsCount: slotsCount ?? this.slotsCount,
      percentage: percentage ?? this.percentage,
    );
  }
}

class DirectorSaving extends DirectorState {}