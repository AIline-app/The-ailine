import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theIline/core/api_client/api_client.dart';
import 'package:theIline/core/theme/text_styles.dart';
import 'package:theIline/core/widgets/action_button.dart';
import 'package:theIline/data/repository/car_wash_repository.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:theIline/core/widgets/custom_text_field.dart';
import 'package:theIline/presentation/client/widgets/car_wash_time_modal.dart';
import 'package:theIline/presentation/client/widgets/count_down_modal.dart';
import 'package:theIline/presentation/client/widgets/star_modal.dart';
import 'package:theIline/routes.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../../core/widgets/popup_contents/no_authorized.dart';
import '../../../core/widgets/popup_sheet.dart';
import '../../../data/bloc/popup_store/popup_bloc.dart';
import '../../../data/bloc/popup_store/popup_event.dart';
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

  void _openPopupSheet(BuildContext context) {

    context.read<PopUpBloc>().add(SetPopUp(1));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {

        return PopUpSheet(content: _buildCarWashCards(carWashes));
      },
    );
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

                //Align(alignment: Alignment(0, -0.6), child: StarModal()),

                Align(alignment: Alignment(0, -0.5), child: CountDownModal()),

                GestureDetector(
                  onTap: (){ _openPopupSheet(context); },
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 40,
                      width: 200,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
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
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),

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

  Widget _buildSortTile(String title) {
  return ListTile(
    title: Text(title),
    onTap: () {
      setState(() {
        selectedSortOption = title;
        _sortCarWashes();
        isExpanded = false;
      });
      Navigator.pop(context); // закрыть ExpansionTile
    },
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
