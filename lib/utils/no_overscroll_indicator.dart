import 'package:flutter/material.dart';

class NoOverscrollIndicator extends ScrollBehavior {
  const NoOverscrollIndicator();
  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) {
    return child;
  }
}
