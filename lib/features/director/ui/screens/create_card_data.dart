import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:gghgggfsfs/core/widgets/custom_checkbox.dart';
import 'package:gghgggfsfs/core/widgets/main_text.dart';
import 'package:go_router/go_router.dart';

class CreateCardData extends StatefulWidget {
  const CreateCardData({super.key});

  @override
  State<CreateCardData> createState() => _CreateCardDataState();
}

class _CreateCardDataState extends State<CreateCardData> {
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  bool _saveCardData = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CustomBackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainText(text: 'Добавление счета\nбанковской карты'),
            SizedBox(height: 30),

            _buildCardNumberField(),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildExpiryDateField()),
                SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    labelText: 'CVV',
                    textController: _cvvController,
                    isClicked: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            CustomTextField(
              labelText: '',
              textController: _cardHolderController,
              isClicked: true,
            ),
            SizedBox(height: 20),

            Row(
              children: [
                CustomCheckboxWidget(),
                SizedBox(width: 12),
                Text(
                  'Запомнить данные карты',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            Spacer(),

            Text(
              'Вы можете изменить информацию\nпозже в настройках',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(height: 20),

            CustomButton(onPressed: _saveCard, text: 'Сохранить'),
          ],
        ),
      ),
    );
  }

  void _saveCard() {
    if (_cardNumberController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _cvvController.text.isEmpty ||
        _cardHolderController.text.isEmpty) {
      context.go('/create_admin');
      return;
    }

    print('Номер карты: ${_cardNumberController.text}');
    print('Дата истечения: ${_expiryDateController.text}');
    print('CVV: ${_cvvController.text}');
    print('Держатель карты: ${_cardHolderController.text}');
    print('Сохранить данные: $_saveCardData');

    context.pop();
  }

  Widget _buildCardNumberField() {
    return CustomTextField(
      labelText: 'Номер карты',
      textController: _cardNumberController,
      isClicked: true,
    );
  }

  Widget _buildExpiryDateField() {
    return CustomTextFieldWithFormatter(
      labelText: 'Дата',
      textController: _expiryDateController,
      isClicked: true,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        _ExpiryDateInputFormatter(),
      ],
      maxLength: 5,
    );
  }
}

class CustomTextFieldWithFormatter extends StatefulWidget {
  const CustomTextFieldWithFormatter({
    super.key,
    this.icon,
    this.isClicked = false,
    this.textController,
    required this.labelText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
  });

  final Widget? icon;
  final bool isClicked;
  final TextEditingController? textController;
  final String labelText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  @override
  State<CustomTextFieldWithFormatter> createState() =>
      _CustomTextFieldWithFormatterState();
}

class _CustomTextFieldWithFormatterState
    extends State<CustomTextFieldWithFormatter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 4,
        ),
      ),
      child: TextFormField(
        controller: widget.textController,
        style: TextStyle(fontSize: 20),
        maxLength: widget.maxLength,
        obscureText: !widget.isClicked,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          counterText: "",
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
          label: Text(widget.labelText),
          labelStyle: TextStyle(color: Colors.grey),
          suffixIcon: widget.icon,
        ),
      ),
    );
  }
}

// // Форматтер для номера карты (добавляет пробелы каждые 4 цифры)
// class _CardNumberInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     final text = newValue.text;
//     if (text.length <= 4) {
//       return newValue;
//     }

//     final buffer = StringBuffer();
//     for (int i = 0; i < text.length; i++) {
//       buffer.write(text[i]);
//       if ((i + 1) % 4 == 0 && i + 1 != text.length) {
//         buffer.write(' ');
//       }
//     }

//     final string = buffer.toString();
//     return TextEditingValue(
//       text: string,
//       selection: TextSelection.collapsed(offset: string.length),
//     );
//   }
// }

// Форматтер для даты истечения ддобавляет слэш после месяца
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length <= 2) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1) {
        buffer.write('/');
      }
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
