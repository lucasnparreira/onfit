 import 'package:flutter/material.dart';

class AppText {
  static double getScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 0.8;
    if (width < 600) return 1.0;
    return 1.2;
  }

  static TextStyle heading1(BuildContext context) {
    return TextStyle(
      fontSize: 24 * getScaleFactor(context),
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontSize: 16 * getScaleFactor(context),
    );
  }
  
}

class AppSpacing {
  static double small(BuildContext context) => MediaQuery.of(context).size.width * 0.02;
  static double medium(BuildContext context) => MediaQuery.of(context).size.width * 0.04;
  static double large(BuildContext context) => MediaQuery.of(context).size.width * 0.06;
}

 Widget _buildResponsiveTextField(BuildContext context, {required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: AppText.getScaleFactor(context) * 16),
      ),
    );
  }

  class DeviceUtils {
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 375;
  }

  static bool isLargeTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  static double responsivePadding(BuildContext context) {
    if (isSmallPhone(context)) return 8.0;
    if (isLargeTablet(context)) return 24.0;
    return 16.0;
  }
}

class ResponsiveImage extends StatelessWidget {
  final String assetPath;
  final double maxHeight;

  const ResponsiveImage({super.key, required this.assetPath, this.maxHeight = 200});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = constraints.maxWidth * 0.5;
        return Image.asset(
          assetPath,
          height: imageHeight > maxHeight ? maxHeight : imageHeight,
          fit: BoxFit.contain,
        );
      },
    );
  }
}