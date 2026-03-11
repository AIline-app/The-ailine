import 'package:flutter_bloc/flutter_bloc.dart';

class LoaderCubit extends Cubit<bool> {
  LoaderCubit() : super(false);

  void show() => emit(true);
  void hide() => emit(false);
}