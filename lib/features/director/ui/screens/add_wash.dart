import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/main_text.dart';

import 'package:gghgggfsfs/features/director/ui/bloc/director_bloc.dart';
import 'package:gghgggfsfs/features/director/ui/bloc/director_event.dart';
import 'package:gghgggfsfs/features/director/ui/bloc/director_state.dart';
import 'package:gghgggfsfs/features/director/widgets/persent_dropdown.dart';
import 'package:go_router/go_router.dart';

class AddWash extends StatefulWidget {
  const AddWash({super.key});

  @override
  State<AddWash> createState() => _AddWashState();
}

class _AddWashState extends State<AddWash> {
  late DirectorBloc _directorBloc;

  final TextEditingController _tinController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _slotsController = TextEditingController();

  final FocusNode _tinFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _slotsFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _directorBloc = context.read<DirectorBloc>();
    _directorBloc.add(LoadDirectorData());

    _tinController.addListener(() {
      _directorBloc.add(UpdateCarWashTIN(_tinController.text));
    });

    _nameController.addListener(() {
      _directorBloc.add(UpdateCarWashName(_nameController.text));
    });

    _addressController.addListener(() {
      _directorBloc.add(UpdateCarWashAddress(_addressController.text));
    });

    _slotsController.addListener(() {
      final slots = int.tryParse(_slotsController.text) ?? 0;
      _directorBloc.add(UpdateSlotsCount(slots));
    });
  }

  @override
  void dispose() {
    _tinController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _slotsController.dispose();
    _tinFocus.dispose();
    _nameFocus.dispose();
    _addressFocus.dispose();
    _slotsFocus.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeString = picked.format(context);
      final state = _directorBloc.state;

      if (state is DirectorLoaded) {
        final currentStartTime = isStart ? timeString : state.carWash.startTime;
        final currentEndTime = isStart ? state.carWash.endTime : timeString;

        _directorBloc.add(UpdateWorkingHours(currentStartTime, currentEndTime));
      }
    }
  }

  Widget _buildTimeBox({
    required String label,
    required String? time,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 4,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time ?? label,
                style: TextStyle(
                  fontSize: 16,
                  color: time == null ? Colors.grey : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.access_time,
                color:
                    time == null
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required String labelText,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              errorText != null
                  ? Colors.red
                  : (focusNode.hasFocus
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline),
          width: 4,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        style: TextStyle(fontSize: 20),
        decoration: InputDecoration(
          counterText: "",
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey),
          suffixIcon: suffixIcon,
          errorText: errorText,
          errorStyle: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  String? _validateTIN(String value) {
    if (value.isEmpty) return 'Поле обязательно для заполнения';
    if (value.length < 3) return 'ТОО должно содержать минимум 3 символа';
    return null;
  }

  String? _validateName(String value) {
    if (value.isEmpty) return 'Поле обязательно для заполнения';
    if (value.length < 3) return 'Название должно содержать минимум 3 символа';
    return null;
  }

  String? _validateAddress(String value) {
    if (value.isEmpty) return 'Поле обязательно для заполнения';
    if (value.length < 5) return 'Адрес должен содержать минимум 5 символов';
    return null;
  }

  String? _validateSlots(String value) {
    if (value.isEmpty) return 'Поле обязательно для заполнения';
    final slots = int.tryParse(value);
    if (slots == null || slots <= 0)
      return 'Количество слотов должно быть больше 0';
    if (slots > 50) return 'Максимальное количество слотов: 50';
    return null;
  }

  bool _isFormValid(CarWashModel carWash) {
    final tinValid = _validateTIN(_tinController.text) == null;
    final nameValid = _validateName(_nameController.text) == null;
    final addressValid = _validateAddress(_addressController.text) == null;
    final slotsValid = _validateSlots(_slotsController.text) == null;
    final timeValid =
        carWash.startTime.isNotEmpty && carWash.endTime.isNotEmpty;
    final percentageValid = carWash.percentage > 0;

    print('Form validation:');
    print('TIN: ${_tinController.text} -> $tinValid');
    print('Name: ${_nameController.text} -> $nameValid');
    print('Address: ${_addressController.text} -> $addressValid');
    print('Slots: ${_slotsController.text} -> $slotsValid');
    print('Times: ${carWash.startTime} - ${carWash.endTime} -> $timeValid');
    print('Percentage: ${carWash.percentage} -> $percentageValid');

    return tinValid &&
        nameValid &&
        addressValid &&
        slotsValid &&
        timeValid &&
        percentageValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<DirectorBloc, DirectorState>(
        listener: (context, state) {
          if (state is DirectorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is DirectorSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is DirectorLoaded) {
            // Обновляем контроллеры только если данные загружены впервые
            if (_tinController.text.isEmpty && state.carWash.tin.isNotEmpty) {
              _tinController.text = state.carWash.tin;
            }
            if (_nameController.text.isEmpty && state.carWash.name.isNotEmpty) {
              _nameController.text = state.carWash.name;
            }
            if (_addressController.text.isEmpty &&
                state.carWash.address.isNotEmpty) {
              _addressController.text = state.carWash.address;
            }
            if (_slotsController.text.isEmpty && state.carWash.slotsCount > 0) {
              _slotsController.text = state.carWash.slotsCount.toString();
            }
          }
        },

        builder: (context, state) {
          if (state is DirectorLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Загрузка данных...'),
                ],
              ),
            );
          }

          if (state is DirectorLoaded) {
            final carWash = state.carWash;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MainText(text: 'Подключение автомойки'),
                        SizedBox(height: 40),

                        _buildCustomTextField(
                          labelText: "ТОО",
                          controller: _tinController,
                          focusNode: _tinFocus,
                          keyboardType: TextInputType.text,
                          errorText:
                              _tinController.text.isNotEmpty
                                  ? _validateTIN(_tinController.text)
                                  : null,
                        ),
                        SizedBox(height: 25),

                        _buildCustomTextField(
                          labelText: "Название",
                          controller: _nameController,
                          focusNode: _nameFocus,
                          errorText:
                              _nameController.text.isNotEmpty
                                  ? _validateName(_nameController.text)
                                  : null,
                        ),
                        SizedBox(height: 25),

                        _buildCustomTextField(
                          labelText: "Адрес",
                          controller: _addressController,
                          focusNode: _addressFocus,
                          suffixIcon: Material(
                            shape: CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Открытие карты...')),
                                );
                              },
                              child: Ink.image(
                                image: AssetImage('assets/icons/2gis.png'),
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                          errorText:
                              _addressController.text.isNotEmpty
                                  ? _validateAddress(_addressController.text)
                                  : null,
                        ),
                        SizedBox(height: 25),

                        MainText(text: 'Укажите время\nработы автомойки'),
                        SizedBox(height: 15),

                        Row(
                          children: [
                            _buildTimeBox(
                              label: 'Начало',
                              time:
                                  carWash.startTime.isNotEmpty
                                      ? carWash.startTime
                                      : null,
                              onTap: () => _selectTime(true),
                            ),
                            SizedBox(width: 16),
                            _buildTimeBox(
                              label: 'Конец',
                              time:
                                  carWash.endTime.isNotEmpty
                                      ? carWash.endTime
                                      : null,
                              onTap: () => _selectTime(false),
                            ),
                          ],
                        ),
                        SizedBox(height: 25),

                        _buildCustomTextField(
                          labelText: "Количество слотов",
                          controller: _slotsController,
                          focusNode: _slotsFocus,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          maxLength: 2,
                          errorText:
                              _slotsController.text.isNotEmpty
                                  ? _validateSlots(_slotsController.text)
                                  : null,
                        ),
                        SizedBox(height: 25),

                        Container(
                          padding: EdgeInsets.only(top: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 4,
                            ),
                          ),
                          child: PercentDropdown(
                            onPercentageChanged: (percentage) {
                              print('Percentage selected: $percentage');
                              _directorBloc.add(UpdatePercentage(percentage));
                            },
                            initialPercentage: carWash.percentage,
                          ),
                        ),
                        SizedBox(height: 40),

                        BlocBuilder<DirectorBloc, DirectorState>(
                          builder: (context, state) {
                            print('Current state: ${state.runtimeType}');
                            bool canSubmit = false;
                            if (state is DirectorLoaded) {
                              canSubmit = _isFormValid(state.carWash);
                            }

                            return CustomButton(
                              text: "Далее",
                              onPressed:
                                  canSubmit
                                      ? () => context.push('/add_service')
                                      : null,
                            );
                          },
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Произошла ошибка при загрузке данных'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _directorBloc.add(LoadDirectorData());
                  },
                  child: Text('Попробовать снова'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
