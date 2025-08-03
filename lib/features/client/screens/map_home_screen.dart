import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/api_client/api_client.dart';
import 'package:gghgggfsfs/core/localization/generated/l10n.dart';
import 'package:gghgggfsfs/data/repository/car_wash_repository.dart';
import 'package:gghgggfsfs/features/auth/screens/login_dialog.dart';
import 'package:gghgggfsfs/features/client/widgets/star_modal.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
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
  String selectedSortOption = S.current.common_sort_by;
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
    return Scaffold(
      body: FutureBuilder<List<CarWashModel>>(
        future: _futureCarWashes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(S.current.common_loading_error));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(S.current.common_no_carwashes));
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
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _showLoginDialog(context);
                },
                child: Container(),
              ),
              // Align(alignment: Alignment(0, -0.7), child: StarModal()),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildCarWashCards(carWashes),
              ),
            ],
          );
        },
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
                    title: Text(S.current.common_sort_distance),
                    onTap: () {
                      setState(() {
                        selectedSortOption = S.current.common_sort_distance;
                        _sortCarWashes();
                        isExpanded = false;
                      });
                    },
                  ),
                  ListTile(
                    title: Text(S.current.common_sort_queue),
                    onTap: () {
                      setState(() {
                        selectedSortOption = S.current.common_sort_queue;
                        _sortCarWashes();
                        isExpanded = false;
                      });
                    },
                  ),
                  ListTile(
                    title: Text(S.current.common_sort_rating),
                    onTap: () {
                      setState(() {
                        selectedSortOption = S.current.common_sort_rating;
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
    if (selectedSortOption == S.current.common_sort_distance) {
      carWashes.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedSortOption == S.current.common_sort_queue) {
      carWashes.sort((a, b) => a.slots.compareTo(b.slots));
    } else if (selectedSortOption == S.current.common_sort_rating) {
      carWashes.sort((a, b) => b.rating.compareTo(a.rating));
    }
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const LoginDialog(),
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
