import 'package:openapi/openapi.dart';

class CartState {
  final List<ServicesRead> selectedServices;
  final int totalPrice;
  final String? selectedDate; // Для будущего использования

  const CartState({
    this.selectedServices = const [],
    this.totalPrice = 0,
    this.selectedDate,
  });

  CartState copyWith({
    List<ServicesRead>? selectedServices,
    int? totalPrice,
    String? selectedDate,
  }) {
    return CartState(
      selectedServices: selectedServices ?? this.selectedServices,
      totalPrice: totalPrice ?? this.totalPrice,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
