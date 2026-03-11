import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/custom_back_button.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:theIline/core/widgets/custom_text_field.dart';
import 'package:theIline/presentation/auth/screens/otp_signup_screen.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/bloc/login_view_model/login_repository_imp.dart';
import '../../../data/bloc/login_view_model/signup_cubit.dart';
import '../../../data/bloc/login_view_model/signup_state.dart';

class PhoneSignupScreen extends StatefulWidget {
  const PhoneSignupScreen({super.key});

  @override
  State<PhoneSignupScreen> createState() => _PhoneSignupScreenState();
}

class _PhoneSignupScreenState extends State<PhoneSignupScreen> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignupCubit(AuthRepositoryImpl()),
      child: BlocBuilder<SignupCubit, SignupState>(
        builder: (context, state) {
          final cubit = context.read<SignupCubit>();

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: CustomBackButton(),
              backgroundColor: Colors.white,
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 50 -
                          kToolbarHeight -
                          MediaQuery.of(context).padding.top,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Регистрация",
                            style: Theme.of(context).textTheme.displayLarge,
                          ),

                          const SizedBox(height: 24),

                          Text(
                            "Введите данные",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),

                          const SizedBox(height: 20),

                          /// 🔹 Username
                          CustomTextField(
                            labelText: "Имя пользователя",
                            keyboardType: TextInputType.text,
                            onChanged: cubit.usernameChanged,
                          ),

                          const SizedBox(height: 15),

                          /// 🔹 Phone
                          CustomTextField(
                            labelText: "Номер телефона",
                            keyboardType: TextInputType.phone,
                            onChanged: cubit.phoneChanged,
                          ),

                          const SizedBox(height: 15),

                          /// 🔹 Password
                          CustomTextField(
                            labelText: "Придумайте пароль",
                            obscureText: !isClicked,
                            onChanged: cubit.passwordChanged,
                            icon: InkWell(
                              onTap: () => setState(() => isClicked = !isClicked),
                              child: Icon(
                                isClicked
                                    ? IconsaxPlusLinear.eye
                                    : IconsaxPlusLinear.eye_slash,
                                size: 21,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          Text(
                            "На данный номер телефона будет отправлен СМС-код для подтверждения",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),

                          if (state.error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              state.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],

                          const Spacer(),

                          CustomButton(
                            text: state.loading ? "..." : "Далее",
                            onPressed: state.loading
                                ? null
                                : () async {
                              final ok =
                              await context.read<SignupCubit>().submit();
                              if (!context.mounted) return;
                              if (ok) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const OtpSignupScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}