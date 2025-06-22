import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/api_client/api_client.dart';
import 'package:gghgggfsfs/data/repository/car_wash_repository.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:gghgggfsfs/presentation/client/widgets/car_wash_time_modal.dart';
import 'package:gghgggfsfs/presentation/client/widgets/count_down_modal.dart';
import 'package:gghgggfsfs/presentation/client/widgets/star_modal.dart';
import 'package:gghgggfsfs/routes.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../../data/model_car_wash/model_car_wash.dart';
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
  String selectedSortOption = 'Сортировать по';
  bool isExpanded = false;

  final CarWashRepository carWashRepository = CarWashRepository(
    apiClient: ApiClient(),
  );
  late Future<List<CarWashModel>> _futureCarWashes;
  List<CarWashModel> carWashes = [];

  int selectedIndex = 0;

  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureCarWashes = carWashRepository.getAllCarWashes();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Tab 1', 'Tab 2'];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: FutureBuilder<List<CarWashModel>>(
          future: _futureCarWashes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Ошибка загрузки автомоек'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Нет доступных автомоек'));
            }

            carWashes = snapshot.data!;

            return Stack(
              children: [
                YandexMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    _addPlacemarks(carWashes);
                  },
                  mapObjects: mapObjects,
                ),

                Positioned(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _showLoginDialog(context);
                    },
                    child: Container(),
                  ),
                ),

                Align(alignment: Alignment(0, -0.7), child: StarModal()),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildCarWashCards(carWashes),
                ),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  // Alert Dialog for sign in

  Widget _buildCarWashCards(List<CarWashModel> carWashes) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: ExpansionTile(
                initiallyExpanded: isExpanded,
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    isExpanded = expanded;
                  });
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
                      setState(() {
                        selectedSortOption = 'Расстояние';
                        _sortCarWashes();
                        isExpanded = false;
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Очередь'),
                    onTap: () {
                      setState(() {
                        selectedSortOption = 'Очередь';
                        _sortCarWashes();
                        isExpanded = false;
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Рейтинг'),
                    onTap: () {
                      setState(() {
                        selectedSortOption = 'Рейтинг';
                        _sortCarWashes();
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
                    setState(() {
                      selectedIndex = index;
                      _moveToCarWash(carWashes[index]);
                      _addPlacemarks(carWashes);
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

  void _addPlacemarks(List<CarWashModel> carWashes) {
    final hasCoordinates = carWashes.any(
      (wash) => wash.latitude != null && wash.longitude != null,
    );

    if (!hasCoordinates) {
      setState(() => mapObjects = []);
      return;
    }

    setState(() {
      mapObjects =
          carWashes
              .where((wash) => wash.latitude != null && wash.longitude != null)
              .map((wash) {
                final isSelected = carWashes[selectedIndex].id == wash.id;
                return PlacemarkMapObject(
                  mapId: MapObjectId(wash.id.toString()),
                  point: Point(
                    latitude: wash.latitude!,
                    longitude: wash.longitude!,
                  ),
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
                    setState(() {
                      selectedIndex = carWashes.indexWhere(
                        (w) => w.id == int.parse(mapObject.mapId.value),
                      );
                    });
                  },
                );
              })
              .toList();
    });
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

  void _sortCarWashes() {
    if (selectedSortOption == 'Расстояние') {
      carWashes.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedSortOption == 'Очередь') {
      carWashes.sort((a, b) => a.slots.compareTo(b.slots));
    } else if (selectedSortOption == 'Рейтинг') {
      carWashes.sort((a, b) => b.rating.compareTo(a.rating));
    }
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
                              Navigator.pushNamed(context, AppRoutes.reg);
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
                          Container(
                            width: 150,
                            height: 2,
                            color: MainColors.mainBlue,
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
        );
      },
    );
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
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: Colors.black),
      ),
    );
  }
}
