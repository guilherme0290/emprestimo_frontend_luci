import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String imageAsset;
  final BoxFit fit;
  final Alignment alignment;
  final double overlayOpacity;
  final Color? overlayColor;

  const AppBackground({
    super.key,
    required this.child,
    this.imageAsset = 'assets/img/money_background.png',
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.overlayOpacity = 0.95,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveOverlayColor =
        overlayColor ?? Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imageAsset),
              fit: fit,
              alignment: alignment,
            ),
          ),
        ),
        Container(
          color: effectiveOverlayColor.withOpacity(overlayOpacity),
        ),
        child,
      ],
    );
  }
}
