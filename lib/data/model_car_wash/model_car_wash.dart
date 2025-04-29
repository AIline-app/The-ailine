class CarWashModel {
 final int id;
 final String name;
  final double latitude;
 final double longitude;
 final int queueLength;
 final int boxCount;
 final double rating;
 final double distance;

  CarWashModel({
   required this.id,
   required this.name,
   required this.latitude,
   required this.longitude,
    required this.queueLength,
   required this.boxCount,
   required this.rating,
   required this.distance,
  });

 factory CarWashModel.fromJson(Map<String, dynamic> json) {
   return CarWashModel(
     id: json['id'],
     name: json['name'],
     latitude: json['latitude'],
     longitude: json['longitude'],
     queueLength: json['queue_length'] ?? 0,
     boxCount: json['box_count'] ?? 0,
     rating: (json['rating'] ?? 0).toDouble(),
     distance: (json['distance'] ?? 0).toDouble(),
    );
  }
}

