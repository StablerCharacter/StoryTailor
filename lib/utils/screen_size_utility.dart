import 'package:flutter/widgets.dart';

class ScreenSizeUtility {
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 960.0;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 640.0;
  }
}
