import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openapi/openapi.dart';
import 'package:theIline/core/theme/text_styles.dart';
import 'package:theIline/presentation/client/screens/parseLocation.dart';
import 'package:theIline/presentation/client/widgets/count_down_modal.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../../core/widgets/popup_sheet.dart';
import '../../../data/bloc/carwash_store/carwash_cubit.dart';
import '../../../data/bloc/carwash_store/carwash_state.dart';
import '../../../data/bloc/popup_store/popup_bloc.dart';
import '../../../data/bloc/popup_store/popup_event.dart';
import '../../../data/model_car_wash/model_car_wash.dart';
import '../../../core/widgets/car_wash_card.dart';

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({super.key});

  @override
  State<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  late YandexMapController mapController;
  List<MapObject> mapObjects = [];
  String selectedSortOption = 'Сортировать по';
  bool isExpanded = false;
  List<CarWashModel> carWashes = [];

  int selectedIndex = 0;

  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<CarWashCubit>().load();
  }

  void _openPopupSheet(BuildContext context, carWas) {

    context.read<PopUpBloc>().add(SetPopUp(1));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return PopUpSheet(content: _buildCarWashCards(carWas));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CarWashCubit, CarWashState>(
        builder: (context, state) {
          if (state is CarWashLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CarWashError) {
            return Center(child: Text('Ошибка загрузки автомоек: ${state.message}'));
          }
          if (state is! CarWashLoaded || state.items.isEmpty) {
            return const Center(child: Text('Нет доступных автомоек'));
          }

          final carWashes = state.items;
          final selectedIndex = state.selectedIndex;

          return Stack(
            children: [
              YandexMap(
                onMapCreated: (controller) {
                  mapController = controller;
                  _addPlacemarks(carWashes, selectedIndex);
                },
                mapObjects: mapObjects,
              ),

              const Align(alignment: Alignment(0, -0.5), child: CountDownModal()),

              GestureDetector(
                onTap: () => _openPopupSheet(context, carWashes),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 40,
                    width: 200,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Alert Dialog for sign in

  Widget _buildCarWashCards(List<CarWashPrivateRead> carWashes) {
      return Container(
        height: 400,
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 3,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                initiallyExpanded: isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() => isExpanded = expanded);
                },
                title: Text(
                  selectedSortOption,
                  style: AppTextStyles.body,
                ),
                trailing: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                children: [
                  _buildSortTile('Расстояние'),
                  _buildSortTile('Очередь'),
                  _buildSortTile('Рейтинг'),
                ],
              ),
            ),
          ),
        ),

        Expanded(
              child: ListView.separated(
                itemCount: carWashes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        _moveToCarWash(carWashes[index]);
                        _addPlacemarks(carWashes, index);
                      });
                    },
                    child: CarWashCard(
                      carWash: carWashes[index],
                      isSelected: index == selectedIndex,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildSortTile(String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        final cubit = context.read<CarWashCubit>();

        if (title == 'Расстояние') cubit.setSort(CarWashSort.distance);
        if (title == 'Очередь') cubit.setSort(CarWashSort.queue);
        if (title == 'Рейтинг') cubit.setSort(CarWashSort.rating);

        Navigator.pop(context);
      },
    );
  }

  void _addPlacemarks(List<CarWashPrivateRead> carWashes, int selectedIndex) {
    setState(() {
      mapObjects = carWashes
          .map((wash) {
        final point = parseLocation(wash.location);
        if (point == null) return null;

        final isSelected = carWashes[selectedIndex].id == wash.id;

        return PlacemarkMapObject(
          mapId: MapObjectId(wash.id),
          point: point,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(
                isSelected
                    ? 'assets/icons/marker_selected.png'
                    : 'assets/icons/marker.png',
              ),
              scale: isSelected ? 1.4 : 1.0,
            ),
          ),
          onTap: (mapObject, point) {
            final idx = carWashes.indexWhere((w) => w.id == mapObject.mapId.value);

            if (idx != -1) {
              context.read<CarWashCubit>().select(idx);
              _moveToCarWash(carWashes[idx]);
              _addPlacemarks(carWashes, idx);
            }
          },
        );
      })
          .whereType<PlacemarkMapObject>()
          .toList();
    });
  }
  void _moveToCarWash(CarWashPrivateRead wash) {
    final point = parseLocation(wash.location);
    if (point == null) return;

    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: point,
          zoom: 15,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 1.2,
      ),
    );
  }

  void _sortCarWashes() {
    if (selectedSortOption == 'Расстояние') {
      carWashes.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedSortOption == 'Очередь') {
      carWashes.sort((a, b) => a.slots.compareTo(b.slots));
    } else if (selectedSortOption == 'Рейтинг') {
      carWashes.sort((a, b) => b.rating.compareTo(a.rating));
    }
  }
}

class ArrivalHint extends StatelessWidget {
  const ArrivalHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: Colors.black),
      ),
    );
  }
}
