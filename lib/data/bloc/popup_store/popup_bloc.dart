import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theIline/data/bloc/popup_store/popup_event.dart';
import 'package:theIline/data/bloc/popup_store/popup_state.dart';

class PopUpBloc extends Bloc<PopUpEvent, PopUpState> {
  PopUpBloc() : super(PopUpState()) {
    on<SetPopUp>((event, emit) {
      emit(state.copyWith(popup: event.popup, isLoading: false));
    });
    on<ShowLoading>((event, emit) {
      emit(state.copyWith(isLoading: true));
    });

    on<HideLoading>((event, emit) {
      emit(state.copyWith(isLoading: false));
    });

    on<SetShowSearch>((event, emit) {
      emit(state.copyWith(showSearch: event.show));
    });
  }

}
