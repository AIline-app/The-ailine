import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:gghgggfsfs/data/models/model_car_wash/model_car_wash.dart';
import 'package:gghgggfsfs/features/client/map_bloc.dart';
import 'package:gghgggfsfs/features/client/map_event.dart';
import 'package:gghgggfsfs/features/client/map_state.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../../core/widgets/car_wash_card.dart';
import '../themes/main_colors.dart';

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({super.key});

  @override
  State<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  late YandexMapController mapController;
  List<MapObject> mapObjects = [];
  bool isExpanded = false;
  String selectedSortOption = 'Сортировать по';

  @override
  void initState() {
    super.initState();
    context.read<CarWashBloc>().add(LoadCarWashes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showLoginDialog(context),
        child: BlocBuilder<CarWashBloc, CarWashState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final carWashes = state.visibleCarWashes;
            final selectedIndex = state.selectedIndex;

            if (carWashes.isEmpty) {
              return const Center(child: Text('Нет доступных автомоек'));
            }

            _addPlacemarks(carWashes, selectedIndex);

            return Stack(
              children: [
                YandexMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    _moveToCarWash(carWashes[selectedIndex]);
                  },
                  mapObjects: mapObjects,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildCarWashCards(context, carWashes, selectedIndex),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarWashCards(
    BuildContext context,
    List<CarWashModel> carWashes,
    int selectedIndex,
  ) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: ExpansionTile(
                initiallyExpanded: isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() => isExpanded = expanded);
                },
                title: Text(
                  selectedSortOption,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
                children: [
                  ListTile(
                    title: const Text('Расстояние'),
                    onTap: () {
                      context.read<CarWashBloc>().add(
                        SortCarWashes('Расстояние'),
                      );
                      setState(() {
                        selectedSortOption = 'Расстояние';
                        isExpanded = false;
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Очередь'),
                    onTap: () {
                      context.read<CarWashBloc>().add(SortCarWashes('Очередь'));
                      setState(() {
                        selectedSortOption = 'Очередь';
                        isExpanded = false;
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Рейтинг'),
                    onTap: () {
                      context.read<CarWashBloc>().add(SortCarWashes('Рейтинг'));
                      setState(() {
                        selectedSortOption = 'Рейтинг';
                        isExpanded = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: carWashes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    context.read<CarWashBloc>().add(SelectCarWash(index));
                    _moveToCarWash(carWashes[index]);
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

  void _addPlacemarks(List<CarWashModel> carWashes, int selectedIndex) {
    mapObjects =
        carWashes.where((w) => w.latitude != null && w.longitude != null).map((
          wash,
        ) {
          final isSelected = wash.id == carWashes[selectedIndex].id;
          return PlacemarkMapObject(
            mapId: MapObjectId(wash.id.toString()),
            point: Point(latitude: wash.latitude!, longitude: wash.longitude!),
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
              final tappedIndex = carWashes.indexWhere(
                (w) => w.id.toString() == mapObject.mapId.value,
              );
              context.read<CarWashBloc>().add(SelectCarWash(tappedIndex));
            },
          );
        }).toList();
  }

  void _moveToCarWash(CarWashModel wash) {
    if (wash.latitude == null || wash.longitude == null) return;

    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: wash.latitude!, longitude: wash.longitude!),
          zoom: 15,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 1.2,
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Center(
            child: Container(
              width: 800,
              height: 830,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 52,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 100,
                        left: 20,
                        right: 20,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Вход',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 32,
                                color: Color(0xff1F3D59),
                              ),
                            ),
                            SizedBox(height: 30),
                            CustomTextField(labelText: 'Номер телефона'),
                            SizedBox(height: 20),
                            CustomTextField(labelText: 'Пароль'),
                            SizedBox(height: 25),
                            Text(
                              'Забыли пароль?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff228CEE),
                              ),
                            ),
                            SizedBox(height: 25),
                            CustomButton(text: 'Войти', onPressed: () {}),
                            SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                context.push('/reg');
                              },

                              child: Text(
                                'Регистрация',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: MainColors.mainBlue,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              child: Container(
                                width: 150,
                                height: 2,
                                color: MainColors.mainBlue,
                              ),
                            ),
                            SizedBox(height: 90),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                overlayColor: Colors.transparent,
                              ),
                              child: Text(
                                'Стать партнером',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w600,
                                  color: MainColors.mainOrrange,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              child: Container(
                                width: 220,
                                height: 2,
                                color: MainColors.mainOrrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
