import 'package:openapi/openapi.dart';

class BoxesState {
  final bool loading;
  final List<Box> boxes;
  final Box? selectedBox;
  final String? error;

  const BoxesState({
    required this.loading,
    required this.boxes,
    this.selectedBox,
    this.error,
  });

  const BoxesState.initial()
      : loading = false,
        boxes = const [],
        selectedBox = null,
        error = null;

  BoxesState copyWith({
    bool? loading,
    List<Box>? boxes,
    Box? selectedBox,
    String? error,
  }) {
    return BoxesState(
      loading: loading ?? this.loading,
      boxes: boxes ?? this.boxes,
      selectedBox: selectedBox ?? this.selectedBox,
      error: error,
    );
  }
}
