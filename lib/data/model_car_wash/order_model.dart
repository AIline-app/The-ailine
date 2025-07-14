import 'package:gghgggfsfs/data/model_car_wash/user_model.dart';

import 'model_car_wash.dart';

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