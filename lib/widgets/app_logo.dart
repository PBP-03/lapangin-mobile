import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 40,
    this.assetPath = 'assets/images/logo/logo.png',
    this.fit = BoxFit.contain,
    this.fallbackColor,
  });

  final double size;
  final String assetPath;
  final BoxFit fit;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.sports_soccer,
          size: size,
          color: fallbackColor ?? Theme.of(context).colorScheme.onSurface,
        );
      },
    );
  }
}
