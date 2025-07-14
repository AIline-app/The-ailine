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