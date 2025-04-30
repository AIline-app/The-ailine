import 'package:flutter/material.dart';
import 'package:gghgggfsfs/data/repository/car_wash_repository.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../data/model_car_wash/model_car_wash.dart';
import '../../core/widgets/car_wash_card.dart';

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
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildCarWashCards(carWashes),
              ),
              Center(
                child: Container(
                  width: 450,
                  height: 800,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: 'Номер телефона',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Text(
                          'Забыли пароль?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff228CEE),
                          ),
                        ),
                        SizedBox(height: 25,),
                        SizedBox(
                          width: 328,
                          height: 96,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              backgroundColor: Color(0xff228CEE),
                              foregroundColor: Colors.white
                            ),
                            onPressed: () {},
                            child: Text('Войти', style: TextStyle(fontSize: 30),),
                          ),
                        ),
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
