import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theIline/core/widgets/popup_contents/no_authorized.dart';
import 'package:theIline/core/widgets/popup_sheet.dart';

import '../../data/bloc/popup_store/popup_bloc.dart';
import '../../data/bloc/popup_store/popup_event.dart';
import 'action_button.dart';

class SkeletonContainer extends StatelessWidget {
  const SkeletonContainer({
    super.key,
    required this.child,
    this.showActionButton = true,
  });

  final Widget child;
  final bool showActionButton;

  void _openPopupSheet(BuildContext context) {
    context.read<PopUpBloc>().add(SetPopUp(1));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {

        return PopUpSheet(content: NoAuthorized());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: child),

          if (showActionButton)
            Positioned(
              top: 35,
              right: 16,
              child: GestureDetector(
                onTap: () => _openPopupSheet(context),
                child: ActionButton(),
              ),
            ),
        ],
      ),
    );
  }
}
