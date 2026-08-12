import 'package:flutter/material.dart';

/// Agentic AI Loading: Sweeping glowing gradient shimmer across the #006A61 primary color
/// indicating the orchestrator is active and reasoning.
class KinAgenticShimmer extends StatefulWidget {
  final Widget child;
  final Color primaryColor;
  final Color shimmerColor;
  final Duration duration;

  const KinAgenticShimmer({
    super.key,
    required this.child,
    this.primaryColor = const Color(0xFF006A61),
    this.shimmerColor = const Color(0xFF0FA89A),
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<KinAgenticShimmer> createState() => _KinAgenticShimmerState();
}

class _KinAgenticShimmerState extends State<KinAgenticShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: [
                widget.primaryColor,
                widget.shimmerColor.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.8),
                widget.shimmerColor.withValues(alpha: 0.9),
                widget.primaryColor,
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0, 0);
  }
}
