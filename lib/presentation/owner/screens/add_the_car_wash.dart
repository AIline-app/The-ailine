import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';


class AddCarwashPage extends StatefulWidget {
  const AddCarwashPage({super.key});

  @override
  State<AddCarwashPage> createState() => _AddCarwashPageState();
}

class _AddCarwashPageState extends State<AddCarwashPage> {
  late YandexMapController mapController;
  final List<MapObject> mapObjects = [];

  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final slotsCtrl = TextEditingController();

  final List<String> times = const ['08:00', '09:00', '10:00', '11:00', '12:00', '18:00', '19:00', '20:00'];
  final List<String> percents = const ['30%', '35%', '40%', '45%', '50%'];

  String startTime = '10:00';
  String endTime = '19:00';
  String percent = '30%';

  bool percentOpen = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    slotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF1F2F3);
    const text = Color(0xFF284457);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: bg,
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(

        child: Stack(
          children: [
            // scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Мойка на Ленинском',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Подключение\nавтомойки',
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(labelText: 'Название'),

                  const SizedBox(height: 14),

                  MapBlock(
                    onMapCreated: (c) => mapController = c,
                    mapObjects: mapObjects,
                    onTapPick: () {

                    },
                  ),

                  const SizedBox(height: 14),

                  CustomTextField(labelText: 'Адрес'),

                  const SizedBox(height: 14),

                  const Text(
                    'Укажите время работы\nавтомойки',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _TimeDropdownField(
                          value: startTime,
                          onTap: () async {
                            final v = await _pickMenuValue(context, times, anchorDx: 0);
                            if (v != null) setState(() => startTime = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _TimeDropdownField(
                          value: endTime,
                          onTap: () async {
                            final v = await _pickMenuValue(context, times, anchorDx: 0);
                            if (v != null) setState(() => endTime = v);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  CustomTextField(labelText: 'Количество слотов'),

                  const SizedBox(height: 14),

                  // Percent dropdown (как на скрине: раскрывается под полем)
                  GestureDetector(
                    onTap: () => setState(() => percentOpen = !percentOpen),
                    child: AbsorbPointer(
                      child: CustomTextField(
                        labelText: 'Процент выплаты мойщикам',
                        readOnly: true,

                      ),
                    ),
                  ),

                  if (percentOpen) ...[
                    const SizedBox(height: 0),
                    _PercentDropdownList(
                      values: percents,
                      selected: percent,
                      onPick: (v) => setState(() {
                        percent = v;
                        percentOpen = false;
                      }),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Upload block
                  _UploadBlock(
                    onPick: () {
                      // TODO: file_picker / image_picker
                    },
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),

            // Bottom fixed "Далее"
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: CustomButton(
                onPressed: () {

                },
                text: 'Далее',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- Widgets ----------

class MapBlock extends StatelessWidget {
  const MapBlock({
    required this.onMapCreated,
    required this.mapObjects,
    required this.onTapPick,
  });

  final void Function(YandexMapController) onMapCreated;
  final List<MapObject> mapObjects;
  final VoidCallback onTapPick;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBFC6CC), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: YandexMap(
                onMapCreated: onMapCreated,
                mapObjects: mapObjects,

                // onMapTap: (Point p) {},
                // onMapLongTap: (Point p) {},
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.30)),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.location_on, size: 54, color: Color(0xFF2D8CFF)),
                  SizedBox(height: 6),
                  Text(
                    'Укажите на карте\nваше местоположение',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF284457),
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTapPick),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TimeDropdownField extends StatelessWidget {
  const _TimeDropdownField({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBFC6CC), width: 2),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: AppTextStyles.bold18Black,
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2D8CFF)),
          ],
        ),
      ),
    );
  }
}

class _PercentDropdownList extends StatelessWidget {
  const _PercentDropdownList({
    required this.values,
    required this.selected,
    required this.onPick,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBFC6CC), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (int i = 0; i < values.length; i++) ...[
            InkWell(
              onTap: () => onPick(values[i]),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerLeft,
                child: Text(
                  values[i],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: values[i] == selected ? const Color(0xFF284457) : const Color(0xFF8E949A),
                  ),
                ),
              ),
            ),
            if (i != values.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6)),
          ]
        ],
      ),
    );
  }
}

class _UploadBlock extends StatelessWidget {
  const _UploadBlock({required this.onPick});
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E5E8), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'JPEG, GIF, PNG, весом не более 10MB',
            style: TextStyle(color: Color(0xFFB3B7BC), fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          const Icon(Icons.image_outlined, size: 34, color: Color(0xFFB3B7BC)),
          const Spacer(),
          SizedBox(
            height: 46,
            width: 170,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2D8CFF), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onPick,
              child: const Text(
                'Загрузить',
                style: TextStyle(color: Color(0xFF2D8CFF), fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
Future<String?> _pickMenuValue(
    BuildContext context,
    List<String> values, {
      double anchorDx = 0,
    }) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final box = context.findRenderObject() as RenderBox?;

  // если нет box (редко) — просто по центру
  final pos = box?.localToGlobal(Offset.zero, ancestor: overlay) ?? Offset(40, 200);

  final rect = RelativeRect.fromLTRB(
    pos.dx + anchorDx,
    pos.dy + 240, // грубо: чтобы меню появлялось ниже (если хочешь супер-точно — привяжем к иконке)
    40,
    0,
  );

  return showMenu<String>(
    context: context,
    position: rect,
    color: Colors.white,
    elevation: 10,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    items: values
        .map(
          (v) => PopupMenuItem<String>(
        value: v,
        child: Text(v, style: AppTextStyles.bold18Black),
      ),
    )
        .toList(),
  );
}
