import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onepicker/theme/AppTheme.dart';

class LoadingIndicator extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.halfTriangleDot(
        color: AppTheme.lightTeal,
        size: 50.0,
      ),
    );
  }
}