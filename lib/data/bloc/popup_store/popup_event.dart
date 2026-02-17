import 'package:equatable/equatable.dart';

abstract class PopUpEvent extends Equatable {
  const PopUpEvent();

  @override
  List<Object?> get props => [];
}

class SetPopUp extends PopUpEvent {
  final int popup;

  const SetPopUp(this.popup);

  @override
  List<Object?> get props => [popup];
}

class ShowLoading extends PopUpEvent {}

class HideLoading extends PopUpEvent {}

class SetShowSearch extends PopUpEvent {
  final bool show;
  SetShowSearch(this.show);
}