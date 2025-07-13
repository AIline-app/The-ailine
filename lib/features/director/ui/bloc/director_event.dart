abstract class DirectorEvent {}

class LoadDirectorData extends DirectorEvent {}

class UpdateCarWashName extends DirectorEvent {
  final String name;
  UpdateCarWashName(this.name);
}

class UpdateCarWashTIN extends DirectorEvent {
  final String tin;
  UpdateCarWashTIN(this.tin);
}

class UpdateCarWashAddress extends DirectorEvent {
  final String address;
  UpdateCarWashAddress(this.address);
}

class UpdateWorkingHours extends DirectorEvent {
  final String startTime;
  final String endTime;
  UpdateWorkingHours(this.startTime, this.endTime);
}

class UpdateSlotsCount extends DirectorEvent {
  final int slotsCount;
  UpdateSlotsCount(this.slotsCount);
}

class UpdatePercentage extends DirectorEvent {
  final double percentage;
  UpdatePercentage(this.percentage);
}

class AddService extends DirectorEvent {
  final ServiceModel service;
  AddService(this.service);
}

class UpdateService extends DirectorEvent {
  final int index;
  final ServiceModel service;
  UpdateService(this.index, this.service);
}

class DeleteService extends DirectorEvent {
  final int index;
  DeleteService(this.index);
}

class ChangeCarType extends DirectorEvent {
  final String carType;
  ChangeCarType(this.carType);
}

class SubmitCarWashData extends DirectorEvent {}

class Clicked extends DirectorEvent {}

class ServiceModel {
  final String title;
  final String subtitle;
  final String minutes;
  final String price;
  final bool isAdditional;

  ServiceModel({
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.price,
    this.isAdditional = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'minutes': minutes,
      'price': price,
      'isAdditional': isAdditional,
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      title: json['title'],
      subtitle: json['subtitle'],
      minutes: json['minutes'],
      price: json['price'],
      isAdditional: json['isAdditional'] ?? false,
    );
  }

  ServiceModel copyWith({
    String? title,
    String? subtitle,
    String? minutes,
    String? price,
    bool? isAdditional,
  }) {
    return ServiceModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      minutes: minutes ?? this.minutes,
      price: price ?? this.price,
      isAdditional: isAdditional ?? this.isAdditional,
    );
  }
}
class SaveCarWashData extends DirectorEvent {}