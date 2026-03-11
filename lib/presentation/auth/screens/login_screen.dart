import 'package:flutter/material.dart';

import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/bloc/login_view_model/login_cubit.dart';
import '../../../data/bloc/login_view_model/login_repository.dart';
import '../../../data/bloc/login_view_model/login_state.dart';
import '../../../data/bloc/user_store/user_cubit.dart';
import '../../../routes.dart';
import '../../client/themes/main_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.repo});

  final AuthRepository repo;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        widget.repo,
        context.read<UserCubit>(),
      ),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (p, n) => p.loading != n.loading || p.error != n.error,
        listener: (context, state) {
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
          if (state.success) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.home,
            );
          }
          if (!state.loading && (state.error == null || state.error!.isEmpty) && state.canSubmit) {
             Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: CustomBackButton(),
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.black,
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                final cubit = context.read<LoginCubit>();

                return AbsorbPointer(
                  absorbing: state.loading,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Вход',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                          color: Color(0xff1F3D59),
                        ),
                      ),
                      const SizedBox(height: 30),

                      CustomTextField(
                        labelText: 'Номер телефона',
                        controller: _phoneCtrl,
                        onChanged: cubit.phoneChanged,
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        labelText: 'Пароль',
                        controller: _passCtrl,
                        obscureText: true,
                        onChanged: cubit.passwordChanged,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Забыли пароль?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff228CEE),
                        ),
                      ),

                      const SizedBox(height: 20),

                    CustomButton(
                      text: state.loading ? 'Входим...' : 'Войти',
                      onPressed: state.canSubmit && !state.loading
                          ? () {
                        context.read<LoginCubit>().submit();
                      }
                          : null,
                    ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.reg);
                        },
                        child: const Text(
                          'Регистрация',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: MainColors.mainBlue,
                          ),
                        ),
                      ),
                      Container(width: 150, height: 2, color: MainColors.mainBlue),

                      const SizedBox(height: 50),

                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Стать партнером',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: MainColors.mainOrrange,
                          ),
                        ),
                      ),
                      Container(width: 220, height: 2, color: MainColors.mainOrrange),

                      if (state.loading) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}