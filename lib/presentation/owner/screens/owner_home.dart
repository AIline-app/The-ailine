import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:theIline/core/widgets/car_wash_card.dart';
import 'package:theIline/presentation/client/screens/parseLocation.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/bloc/carwash_store/carwash_cubit.dart';
import '../../../data/bloc/carwash_store/carwash_state.dart';
import '../../../routes.dart';
import '../../../core/theme/text_styles.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  late YandexMapController mapController;
  List<MapObject> mapObjects = [];
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<CarWashCubit>().load();
  }

  void _addPlacemarks(List<CarWashPrivateRead> carWashes, int selectedIndex) {
    setState(() {
      mapObjects = carWashes
          .map((wash) {
            final point = parseLocation(wash.location);
            if (point == null) return null;

            final isSelected = carWashes.isNotEmpty && carWashes[selectedIndex].id == wash.id;

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
                  _onItemSelected(idx, carWashes);
                }
              },
            );
          })
          .whereType<PlacemarkMapObject>()
          .toList();
    });
  }

  void _onItemSelected(int index, List<CarWashPrivateRead> carWashes) {
    context.read<CarWashCubit>().select(index);
    _moveToCarWash(carWashes[index]);
    _addPlacemarks(carWashes, index);
  }

  void _moveToCarWash(CarWashPrivateRead wash) {
    final point = parseLocation(wash.location);
    if (point == null) return;

    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 15),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1.2),
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
            return Center(child: Text('Ошибка загрузки: ${state.message}'));
          }
          if (state is! CarWashLoaded || state.items.isEmpty) {
            return const Center(child: Text('Нет доступных автомоек'));
          }

          final carWashes = state.items;
          final selectedIndex = state.selectedIndex;

          return Stack(
            children: [
              Positioned.fill(
                child: YandexMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    _addPlacemarks(carWashes, selectedIndex);
                  },
                  mapObjects: mapObjects,
                ),
              ),

              DraggableScrollableSheet(
                initialChildSize: 0.25,
                minChildSize: 0.18,
                maxChildSize: 0.70,
                snap: true,
                snapSizes: const [0.18, 0.32, 0.70],
                builder: (context, scrollController) {
                  return _BottomSheetContent(
                    scrollController: scrollController,
                    items: carWashes,
                    selectedIndex: selectedIndex,
                    onTapItem: (index) => _onItemSelected(index, carWashes),
                    isExpanded: isExpanded,
                    onExpansionChanged: (val) => setState(() => isExpanded = val),
                    currentSort: state.sort,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent({
    required this.scrollController,
    required this.items,
    required this.onTapItem,
    required this.selectedIndex,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.currentSort,
  });

  final ScrollController scrollController;
  final List<CarWashPrivateRead> items;
  final ValueChanged<int> onTapItem;
  final int selectedIndex;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final CarWashSort currentSort;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF1F2F3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [
            BoxShadow(blurRadius: 24, offset: Offset(0, -8), color: Color(0x33000000))
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFB8BEC4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 10),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: onExpansionChanged,
                  title: Text(
                    _getSortTitle(currentSort),
                    style: AppTextStyles.body,
                  ),
                  children: [
                    _buildSortTile(context, 'Расстояние', CarWashSort.distance),
                    _buildSortTile(context, 'Очередь', CarWashSort.queue),
                    _buildSortTile(context, 'Рейтинг', CarWashSort.rating),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return CarWashCard(
                    carWash: item,
                    isSelected: i == selectedIndex,
                    onTap: () {
                      onTapItem(i);
                      Navigator.pushNamed(context, AppRoutes.analytics, arguments: item.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortTitle(CarWashSort sort) {
    switch (sort) {
      case CarWashSort.distance: return 'Расстояние';
      case CarWashSort.queue: return 'Очередь';
      case CarWashSort.rating: return 'Рейтинг';
      default: return 'Сортировать по';
    }
  }

  Widget _buildSortTile(BuildContext context, String title, CarWashSort sort) {
    return ListTile(
      title: Text(title),
      onTap: () {
        context.read<CarWashCubit>().setSort(sort);
        onExpansionChanged(false);
      },
    );
  }
}
