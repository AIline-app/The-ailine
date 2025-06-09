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

class OrderModel {
  final int id;
  final UserModel customer;
  final CarWashModel carWash;
  final DateTime timeStart;
  final int timeWork;
  final double finalPrice;
  final double commission;
  final String status;
  final String statusPayment;
  final bool onSite;
  final double rating;
  final bool rated;
  final bool notified;
  final bool notifiedByAdmin;
  final String cashOutStatus;
  final int boxId;

  OrderModel({
    required this.id,
    required this.customer,
    required this.carWash,
    required this.timeStart,
    required this.timeWork,
    required this.finalPrice,
    required this.commission,
    required this.status,
    required this.statusPayment,
    required this.onSite,
    required this.rating,
    required this.rated,
    required this.notified,
    required this.notifiedByAdmin,
    required this.cashOutStatus,
    required this.boxId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customer: UserModel.fromJson(json['customer']),
      carWash: CarWashModel.fromJson(json['car_wash']),
      timeStart: DateTime.parse(json['time_start']),
      timeWork: json['time_work'],
      finalPrice: (json['final_price'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      status: json['status'],
      statusPayment: json['status_payment'],
      onSite: json['on_site'] == 1,
      rating: (json['rating'] ?? 0).toDouble(),
      rated: json['rated'],
      notified: json['notified'],
      notifiedByAdmin: json['notified_by_admin'],
      cashOutStatus: json['cash_out_status'],
      boxId: json['box_id'],
    );
  }
}

class UserModel {
  final String username;
  final String phone;
  final String typeAuto;
  final String numberAuto;
  final String role;

  UserModel({
    required this.username,
    required this.phone,
    required this.typeAuto,
    required this.numberAuto,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      phone: json['phone'],
      typeAuto: json['type_auto'],
      numberAuto: json['number_auto'],
      role: json['role'],
    );
  }
}

class SlotModel {
  final int id;
  final int washId;
  final int orderId;
  final String status;

  SlotModel({
    required this.id,
    required this.washId,
    required this.orderId,
    required this.status,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'],
      washId: json['wash'],
      orderId: json['order'],
      status: json['status'],
    );
  }
}
