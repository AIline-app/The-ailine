import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/custom_button.dart';

import '../../../../core/widgets/custom_text_field.dart';


Future<void> showAddServiceDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => const AddServiceDialog(),
  );
}

class AddServiceDialog extends StatefulWidget {
  const AddServiceDialog({super.key});

  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  bool extra = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomTextField(labelText: 'Название услуги'),
            const SizedBox(height: 12),
            const CustomTextField(labelText: 'Описание'),
            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(child: CustomTextField(labelText: 'Время')),
                SizedBox(width: 12),
                Expanded(child: CustomTextField(labelText: 'Стоимость')),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => extra = !extra),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE48A13), width: 2),
                    ),
                    child: extra
                        ? const Icon(Icons.check, size: 16, color: Color(0xFFE48A13))
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Доп. услуга',
                  style: TextStyle(
                    color: Color(0xFF284457),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCDD3D8), width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'i',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF9AA3AB)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () => Navigator.pop(context),
                    text: 'Отмена',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      // TODO: save
                      Navigator.pop(context);
                    },
                    text: 'Сохранить',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
