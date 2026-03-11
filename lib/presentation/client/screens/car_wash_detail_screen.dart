import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theIline/core/theme/color_schemes.dart';
import 'package:theIline/core/theme/text_styles.dart';
import 'package:theIline/core/widgets/custom_back_button.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:theIline/core/widgets/custom_checkbox.dart';
import 'package:theIline/presentation/client/screens/payment_warning_screen.dart';
import 'package:theIline/core/widgets/another_service.dart';
import 'package:theIline/core/widgets/type_car_button.dart';

import '../../../core/widgets/car_tarifs.dart';
import '../../../data/bloc/cart_store/cart_cubit.dart';
import '../../../data/bloc/cart_store/cart_state.dart';
import '../../../data/bloc/car_types_store/car_types_cubit.dart';
import '../../../data/bloc/car_types_store/car_types_state.dart';
import '../../../data/bloc/carwash_detail_store/carwash_detail_cubit.dart';
import '../../../data/bloc/carwash_detail_store/carwash_detail_state.dart';
import '../../../data/bloc/carwash_queue_store/carwash_queue_cubit.dart';
import '../../../data/bloc/carwash_queue_store/carwash_queue_state.dart';
import '../../../data/bloc/services_store/services_cubit.dart';
import '../../../data/bloc/services_store/services_state.dart';

class CarWashDetailScreen extends StatefulWidget {
  const CarWashDetailScreen({super.key});

  @override
  State<CarWashDetailScreen> createState() => _CarWashDetailScreenState();
}

class _CarWashDetailScreenState extends State<CarWashDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 241, 241),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<CarWashDetailCubit, CarWashDetailState>(
              listener: (context, state) {
                if (state is CarWashDetailLoaded) {
                  final id = state.item.id;
                  context.read<CarWashQueueCubit>().loadQueue(id);
                  context.read<CarTypesCubit>().loadCarTypes(id);
                  context.read<ServicesCubit>().loadServices(id);
                }
              },
            ),
            BlocListener<ServicesCubit, ServicesState>(
              listener: (context, state) {
                if (state is ServicesLoaded) {
                  context.read<CartCubit>().updateSelectedServices(
                    state.services,
                    state.selectedServiceIds,
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<CarWashDetailCubit, CarWashDetailState>(
              builder: (context, state) {
            if (state is CarWashDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CarWashDetailError) {
              return Center(child: Text('Ошибка: ${state.message}', style: const TextStyle(color: Colors.red)));
            }
            if (state is! CarWashDetailLoaded) {
              return const SizedBox.shrink();
            }
            final carWash = state.item;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(2),
                    child: Row(
                      children: [
                        CustomBackButton(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 350,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/card_car.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          color: const Color(0x891C1C1C),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      carWash.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: Image.asset('assets/icons/2gis.png', width: 19, height: 19, fit: BoxFit.cover),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(carWash.name, style: AppTextStyles.bold28w600, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5),
                              Text('50 метров от вас', style: AppTextStyles.normalLightGrey),
                              const Spacer(),
                              const Text(
                                'Перед вами сейчас:',
                                style: TextStyle(height: 2, color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              BlocBuilder<CarWashQueueCubit, CarWashQueueState>(
                                builder: (context, queueState) {
                                  String amount = '—';
                                  String time = '—:—';
                                  if (queueState is CarWashQueueLoaded) {
                                    amount = queueState.queue.carAmount.toString();
                                    time = queueState.queue.waitTime;
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(amount, style: AppTextStyles.bold40),
                                          const SizedBox(width: 6),
                                          Text('машин', style: AppTextStyles.normalLightGrey),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Вы сможете подъехать к:',
                                        style: TextStyle(height: 2, color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('≈', style: AppTextStyles.bold40),
                                          Text('±$time', style: AppTextStyles.normalLightGrey),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<CarTypesCubit, CarTypesState>(
                    builder: (context, typeState) {
                      if (typeState is CarTypesLoading) {
                        return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()));
                      }
                      if (typeState is CarTypesLoaded) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              children: List.generate(typeState.types.length, (index) {
                                final type = typeState.types[index];
                                final isSelected = typeState.selectedIndex == index;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: TypeCarButton(
                                    onPressed: () => context.read<CarTypesCubit>().selectType(index),
                                    text: type.name,
                                    textColor: isSelected ? Colors.white : customColorScheme.primary,
                                    backgroundColor: isSelected ? customColorScheme.primary : Colors.transparent,
                                  ),
                                );
                              }),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 20),
                  const CarTarifs(),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text('Дополнительные услуги', style: AppTextStyles.title),
                  ),
                  const SizedBox(height: 5),
                  
                  BlocBuilder<CarTypesCubit, CarTypesState>(
                    builder: (context, typeState) {
                      if (typeState is! CarTypesLoaded) return const SizedBox.shrink();
                      final selectedTypeId = typeState.types[typeState.selectedIndex].id;
                      
                      return BlocBuilder<ServicesCubit, ServicesState>(
                        builder: (context, serviceState) {
                          if (serviceState is ServicesLoading) return const Center(child: CircularProgressIndicator());
                          if (serviceState is! ServicesLoaded) return const SizedBox.shrink();

                          final extraServices = serviceState.services.where((s) {
                            return s.isExtra == true && s.carType == selectedTypeId;
                          }).toList();

                          if (extraServices.isEmpty) return const Padding(
                            padding: EdgeInsets.only(left: 20, top: 10),
                            child: Text('Нет доп. услуг для этого типа авто'),
                          );

                          return Column(
                            children: extraServices.map((service) => AnotherService(
                              title: service.name,
                              subtitle: service.description,
                              minutes: service.duration,
                              price: '${service.price}р',
                              isSelected: serviceState.selectedServiceIds.contains(service.id),
                              onTap: () => context.read<ServicesCubit>().toggleService(service.id),
                            )).toList(),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),

                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Вы выбрали', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          BlocBuilder<CartCubit, CartState>(
                            builder: (context, cartState) {
                              return Text('${cartState.totalPrice} р', style: AppTextStyles.bold28Black);
                            },
                          ),
                          const Text('2.02, вторник, 14:00', style: AppTextStyles.bold28Black),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              CustomCheckboxWidget(),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Я подтверждаю дату и время бронирования и ознакомлен с условиями оплаты',
                                  style: AppTextStyles.normal14,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CustomButton(
                      text: 'Записаться',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentWarningScreen()));
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
