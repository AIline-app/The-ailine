import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theIline/core/widgets/tarifs_section.dart';
import 'package:theIline/data/bloc/services_store/services_cubit.dart';
import 'package:theIline/data/bloc/services_store/services_state.dart';
import 'package:theIline/data/bloc/car_types_store/car_types_cubit.dart';
import 'package:theIline/data/bloc/car_types_store/car_types_state.dart';

class CarTarifs extends StatelessWidget {
  const CarTarifs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarTypesCubit, CarTypesState>(
      builder: (context, typeState) {
        if (typeState is! CarTypesLoaded) {
          return const SizedBox.shrink();
        }

        final selectedType = typeState.types[typeState.selectedIndex];

        return BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, serviceState) {
            if (serviceState is ServicesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (serviceState is ServicesError) {
              return Center(child: Text('Ошибка: ${serviceState.message}'));
            }
            if (serviceState is! ServicesLoaded) {
              return const SizedBox.shrink();
            }

            // Фильтруем основные услуги (не доп) для выбранного типа автомобиля
            final mainServices = serviceState.services.where((s) {
              final isMain = s.isExtra != true;
              final isForSelectedType = s.carType == selectedType.id;
              return isMain && isForSelectedType;
            }).toList();

            if (mainServices.isEmpty) {
              return const Center(child: Text('Нет доступных тарифов для этого типа авто'));
            }

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: mainServices.map((service) {
                  final isSelected = serviceState.selectedServiceIds.contains(service.id);
                  return TarifsSection(
                    title: service.name,
                    subtitle: service.description,
                    minutes: service.duration,
                    price: '${service.price}р',
                    isSelected: isSelected,
                    onTap: () => context.read<ServicesCubit>().toggleService(service.id),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
