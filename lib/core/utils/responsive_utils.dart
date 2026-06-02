import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static bool isMobile(BuildContext ctx) => MediaQuery.of(ctx).size.width < 600;
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 && MediaQuery.of(ctx).size.width < 1024;
  static bool isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1024;

  static double hPad(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < 600) return 24.0;
    if (w < 1024) return 40.0;
    return 64.0;
  }

  static double maxWidth(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    return w < 600 ? w : 480.0;
  }

  static Widget centered({required BuildContext ctx, required Widget child}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth(ctx)),
        child: child,
      ),
    );
  }
}
