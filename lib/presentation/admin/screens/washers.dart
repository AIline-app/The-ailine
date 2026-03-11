import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:theIline/routes.dart';

import '../../../core/widgets/custom_back_button.dart';

class WashersPage extends StatelessWidget {
  const WashersPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEFEFEF);
    const primary = Color(0xFF2D8CFF);
    const text = Color(0xFF284457);

    final items = const [
      ('Алексей', '+7 (999) 999-99-99'),
      ('Дмитрий', '+7 (999) 999-99-99'),
      ('Игорь', ''),
      ('Сергей', ''),
      ('Иван', '+7 (999) 999-99-99'),
    ];

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
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 22),

                  const Text(
                    'Мойщики',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: text,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // List
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final name = items[i].$1;
                        final phone = items[i].$2;

                        return _WasherRow(
                          name: name,
                          phone: phone,
                          onMenu: (action) {
                            if (action == _RowAction.edit) {
                              // TODO: open edit
                            } else if (action == _RowAction.delete) {
                              // TODO: confirm + delete
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: CustomButton(text: 'Добавить',
                onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addWashers);
              },),
            ),
          ],
        ),
      ),
    );
  }
}

enum _RowAction { edit, delete }

class _WasherRow extends StatelessWidget {
  const _WasherRow({
    required this.name,
    required this.phone,
    required this.onMenu,
  });

  final String name;
  final String phone;
  final void Function(_RowAction action) onMenu;

  Future<void> _openMenu(BuildContext context) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final button = context.findRenderObject() as RenderBox;

    final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final rect = RelativeRect.fromLTRB(
      topLeft.dx - 165, // сдвиг влево (подгони под пиксель)
      topLeft.dy + 22,  // чуть ниже кнопки
      topLeft.dx,
      0,
    );

    final res = await showMenu<_RowAction>(
      context: context,
      position: rect,
      color: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        PopupMenuItem<_RowAction>(
          value: _RowAction.edit,
          enabled: false,
          child: const Text(
            'Редактировать',
            style: TextStyle(fontSize: 14),
          ),
        ),
        //const PopupMenuDivider(height: 1),
        const PopupMenuItem<_RowAction>(
          value: _RowAction.delete,
          child: Text(
            'Удалить',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );

    if (res != null) onMenu(res);
  }

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFF284457);
    const dots = Color(0xFF2D8CFF);

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
        ),

        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              phone,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: text,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => _openMenu(ctx),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.more_vert, color: dots, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}
