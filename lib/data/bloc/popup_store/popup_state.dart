import 'package:equatable/equatable.dart';

class PopUpState extends Equatable {
  final int popup;
  final bool isLoading;
  final bool showSearch;

  PopUpState({this.popup = 0, this.isLoading = false, this.showSearch = false});

  PopUpState copyWith({int? popup, bool? isLoading, bool? showSearch}) {
    return PopUpState(
      popup: popup ?? this.popup,
      isLoading: isLoading ?? this.isLoading,
      showSearch: showSearch ?? this.showSearch,
    );
  }


  @override
  List<Object?> get props => [popup, isLoading, showSearch];

}
