import 'package:flutter/material.dart';

class BrandedBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Alignment alignment;

  const BrandedBackground({
    super.key,
    required this.child,
    this.opacity = 0.05,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/kin_logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
