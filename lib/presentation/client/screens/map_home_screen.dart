import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/api_client/api_client.dart';
import 'package:gghgggfsfs/core/theme/text_styles.dart';
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
                
                Positioned(
                  top: 20,
                  right: 0,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                    Container(
                      height: 36,
                      width: 36,
                       alignment: Alignment.center,
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Color.fromRGBO(34, 140, 238, 1)
                      ),
                      child: Center(
                        child: IconButton(onPressed: (){
                                            
                        },
                         padding: EdgeInsets.zero, // 👈 важно
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.map, color: Colors.white,)),
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      height: 36,
                      width: 36,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Color.fromRGBO(34, 140, 238, 1)
                      ),
                      child: Center(
                        child: IconButton(onPressed: (){
              
                        }, 
                        padding: EdgeInsets.zero, // 👈 важно
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.list, color: Colors.white,),),
                      ),
                    ),
                     SizedBox(width: 10,),
                  ],),
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
      return DraggableScrollableSheet(
    initialChildSize: 0.45, // стартовая высота
    minChildSize: 0.25,
    maxChildSize: 0.55,
    builder: (context, scrollController) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: Column(
          children: [

            Container(
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 2),
                  ],
                ),
                child: ExpansionTile(
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

  
            Expanded(
              child: ListView.separated(
                controller: scrollController, // 🔥 обязательно
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
    },
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
                      top: 20,
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
                              fontWeight: FontWeight.w500,
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
