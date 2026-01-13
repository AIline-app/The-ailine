import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gghgggfsfs/core/localization/generated/l10n.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:gghgggfsfs/core/widgets/tarifs_client_section.dart';
import 'package:gghgggfsfs/core/widgets/type_car.dart';
import 'package:gghgggfsfs/features/admin/presentation/widgets/add_button.dart';

class CreateManualQueueScreen extends StatefulWidget {
  const CreateManualQueueScreen({super.key});

  @override
  State<CreateManualQueueScreen> createState() =>
      _CreateManualQueueScreenState();
}

class _CreateManualQueueScreenState extends State<CreateManualQueueScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CustomBackButton(), scrolledUnderElevation: 0.sp),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Автомойка Капля',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                labelText: S.current.common_car_number,
                isClicked: true,
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                labelText: S.current.common_what_is_your_name,
                isClicked: true,
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                labelText: S.current.common_phone_number,
                isClicked: true,
              ),
              SizedBox(height: 20.h),
              Text(
                S.current.common_choose_car_type,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: 20.h),
              TypeCar(),
              SizedBox(height: 20.h),
              Text(
                S.current.common_chooose_service,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: 20.h),
              TarifsClientSection(
                title: 'Стандарт',
                subtitle: 'Пена, вода, сушка',
                minutes: '30 мин',
                price: '550р',
              ),
              AddButton(onPressed: () {}, text: 'Добавить'),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
