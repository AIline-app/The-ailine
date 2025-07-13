import 'package:flutter/material.dart';

class PercentDropdown extends StatefulWidget {
  final Function(double)? onPercentageChanged;  
  final double? initialPercentage;

  const PercentDropdown({
    super.key,
    this.onPercentageChanged, 
    this.initialPercentage,   
  });

  @override
  State<PercentDropdown> createState() => _PercentDropdownState();
}

class _PercentDropdownState extends State<PercentDropdown> {
  String? selectedPercent;
  final List<String> percentOptions = ['30%', '35%', '40%', '45%', '50%'];

  @override
  void initState() {
    super.initState();
    if (widget.initialPercentage != null && widget.initialPercentage! > 0) {
      selectedPercent = '${widget.initialPercentage!.toInt()}%';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: selectedPercent,
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.blue,
          size: 32.0,
        ),
        items: percentOptions
            .map(
              (percent) => DropdownMenuItem(
                value: percent,
                child: Text(
                  percent,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedPercent = value;
          });
          
          if (value != null && widget.onPercentageChanged != null) {
            double percentage = double.parse(value.replaceAll('%', ''));
            widget.onPercentageChanged!(percentage);
          }
        },
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          label: const Text('Процент выплаты мойщикам'),
          labelStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}