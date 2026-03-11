import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openapi/openapi.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void updateSelectedServices(List<ServicesRead> services, Set<String> selectedIds) {
    final selectedServices = services.where((s) => selectedIds.contains(s.id)).toList();
    final total = selectedServices.fold<int>(0, (sum, s) => sum + s.price);
    
    emit(state.copyWith(
      selectedServices: selectedServices,
      totalPrice: total,
    ));
  }

  void clear() {
    emit(const CartState());
  }
}
