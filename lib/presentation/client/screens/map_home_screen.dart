import 'package:flutter/material.dart';
import 'package:gghgggfsfs/data/repository/car_wash_repository.dart';
import 'package:gghgggfsfs/presentation/client/widgets/custom_button.dart';
import 'package:gghgggfsfs/presentation/client/widgets/custom_textformfield.dart';
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

  final CarWashRepository carWashRepository = CarWashRepository();
  late Future<List<CarWashModel>> _futureCarWashes;
  List<CarWashModel> carWashes = [];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureCarWashes = carWashRepository.getAllCarWashes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  behavior: HitTestBehavior.opaque, // обязательно
                  onTap: () {
                    _showLoginDialog(context);
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildCarWashCards(carWashes),
              ),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // Alert Dialog for sign in

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(30),
            child: Center(
              child: Container(
                width: double.infinity,
                height: 800,
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
                          onTap: () {
                            Navigator.pop(context);
                          },
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 120,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Вход',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 32,
                              color: MainColors.mainBlue,
                            ),
                          ),
                          SizedBox(height: 30),
                          CustomTextformfield(text_in_button: 'Номер телефона'),
                          SizedBox(height: 20),
                          CustomTextformfield(text_in_button: 'Пароль'),
                          SizedBox(height: 25),
                          Text(
                            'Забыли пароль?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: MainColors.mainBlue,
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            child: Container(
                              width: 95,
                              height: 1,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 25),
                          CustomButton(text_of_button: 'Войти'),
                          SizedBox(height: 20),
                          Text(
                            'Регистрация',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: MainColors.mainBlue,
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            child: Container(
                              width: 150,
                              height: 1,
                              color: MainColors.mainBlue,
                            ),
                          ),
                        ],
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

  void _addPlacemarks(List<CarWashModel> carWashes) {
    setState(() {
      mapObjects =
          carWashes.map((wash) {
            final isSelected = carWashes[selectedIndex].id == wash.id;
            return PlacemarkMapObject(
              mapId: MapObjectId(wash.id.toString()),
              point: Point(latitude: wash.latitude, longitude: wash.longitude),
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
            );
          }).toList();
    });
  }

  void _sortCarWashes() {
    if (selectedSortOption == 'Расстояние') {
      carWashes.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (selectedSortOption == 'Очередь') {
      carWashes.sort((a, b) => a.queueLength.compareTo(b.queueLength));
    } else if (selectedSortOption == 'Рейтинг') {
      carWashes.sort(
        (a, b) => b.rating.compareTo(a.rating),
      ); // рейтинг от большего к меньшему
    }
  }

  Widget _buildCarWashCards(List<CarWashModel> carWashes) {
    return Container(
      height: 240,
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

  void _moveToCarWash(CarWashModel wash) {
    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: wash.latitude, longitude: wash.longitude),
          zoom: 15,
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 1.2,
      ),
    );
  }
}
