import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theIline/presentation/auth/screens/car_signup_screen.dart';
import 'package:theIline/core/widgets/custom_back_button.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:otp_text_field_v2/otp_text_field_v2.dart';
import 'package:bloc/bloc.dart';
import '../../../data/bloc/loader_model/loader_cubit.dart';
import '../../../data/bloc/login_view_model/login_repository_imp.dart';

class OtpSignupScreen extends StatefulWidget {
  const OtpSignupScreen({super.key});

  @override
  State<OtpSignupScreen> createState() => _OtpSignupScreenState();
}

class _OtpSignupScreenState extends State<OtpSignupScreen> {
  final OtpFieldControllerV2 otpController = OtpFieldControllerV2();
  final AuthRepositoryImpl _repo = AuthRepositoryImpl();
  String _currentPin = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(leading: CustomBackButton(), backgroundColor: Colors.white),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Регистрация",
                  style: Theme.of(context).textTheme.displayLarge,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
               
                  children: [
                    Text(
                      "Введите код",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Код будет доставлен в течение 30 секунд. Если код не пришел, проверьте правильность указанного номер телефона и попробуйте еще раз",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(
                      height: 15,
                    ),

                    OTPTextFieldV2(
                      controller: otpController,
                      length: 4,
                      width: MediaQuery.of(context).size.width,
                      textFieldAlignment: MainAxisAlignment.spaceAround,
                      fieldWidth: 45,
                      keyboardType: TextInputType.number,
                      fieldStyle: FieldStyle.underline,
                      outlineBorderRadius: 15,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                      onChanged: (pin) {
                        setState(() {
                          _currentPin = pin;
                        });
                        //print("Changed: $pin");
                      },
                      onCompleted: (pin) {
                        setState(() {
                          _currentPin = pin;
                        });
                        //print("Completed: $pin");
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Text(
                        "Выслать код повторно",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).colorScheme.primary,
                          decorationThickness: 1.5,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                CustomButton(
                  text: "Далее",
                  onPressed: () async {
                    final pin = _currentPin;

                    if (pin.length != 4) return;

                    final loader = context.read<LoaderCubit>();
                    loader.show();

                    final result = await _repo.verifyPhone(code: pin);

                    loader.hide();

                    if (!mounted) return;

                    if (result.success) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarSignupScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result.error ?? 'Ошибка')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
