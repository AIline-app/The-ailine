import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/custom_checkbox.dart';

class AnotherService extends StatelessWidget {
  const AnotherService({
    super.key,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.price,
    this.isSelected = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String minutes;
  final String price;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CustomCheckboxWidget(
        value: isSelected,
        onChanged: (_) => onTap?.call(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xff1F3D59),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            minutes,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff1F3D59),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff228CEE),
            ),
          ),
        ],
      ),
    );
  }
}
