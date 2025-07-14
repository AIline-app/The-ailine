class CarWashModel {
  final int id;
  final String title;
  final String inn;
  final String address;
  final String startTime;
  final String endTime;
  final int slots;
  final String image;
  final double rating;
  final String? lastTime;
  final bool isValidate;
  final bool isActive;
  final double distance;
  final int queueLenght;
  final double? latitude;
  final double? longitude;
  final String? link2gis;

  CarWashModel({
    required this.id,
    required this.title,
    required this.inn,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.slots,
    required this.image,
    required this.rating,
    required this.lastTime,
    required this.distance,
    required this.queueLenght,
    required this.isValidate,
    required this.isActive,
    required this.latitude,
    required this.longitude,
    this.link2gis,
  });

  factory CarWashModel.fromJson(Map<String, dynamic> json) {
    return CarWashModel(
      id: json['id'],
      title: json['title'],
      inn: json['inn'],
      address: json['address'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      slots: json['slots'],
      image: json['image'],
      rating: (json['rating'] ?? 0).toDouble(),
      lastTime: json['last_time'],
      distance: (json['distance'] ?? 0).toDouble(),
      queueLenght: json['queue_Lenght'] ?? 0,
      isValidate: json['is_validate'] == 1,
      isActive: json['is_active'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      link2gis: json['link_2_gis'],
    );
  }
}

