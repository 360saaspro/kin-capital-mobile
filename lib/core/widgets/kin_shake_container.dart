import 'dart:math';
import 'package:flutter/material.dart';
import '../services/haptic_service.dart';

/// Warning/Error UI Container: Gently shakes (horizontal translation)
/// accompanied by an amber #F59E0B border glow and warning haptic sequence.
class KinShakeContainer extends StatefulWidget {
  final Widget child;
  final bool shake;
  final Color errorBorderColor;
  final Duration duration;
  final VoidCallback? onAnimationComplete;

  const KinShakeContainer({
    super.key,
    required this.child,
    this.shake = false,
    this.errorBorderColor = const Color(0xFFF59E0B), // Amber #F59E0B
    this.duration = const Duration(milliseconds: 500),
    this.onAnimationComplete,
  });

  @override
  State<KinShakeContainer> createState() => _KinShakeContainerState();
}

class _KinShakeContainerState extends State<KinShakeContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _offsetAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        widget.onAnimationComplete?.call();
      }
    });

    if (widget.shake) {
      _triggerShake();
    }
  }

  @override
  void didUpdateWidget(covariant KinShakeContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _triggerShake();
    }
  }

  void _triggerShake() {
    KinHaptics.errorSequence();
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        final offset = sin(_controller.value * pi * 8) * 10;
        final showGlow = widget.shake || _controller.isAnimating;

        return Transform.translate(
          offset: Offset(offset, 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: showGlow
                  ? Border.all(color: widget.errorBorderColor, width: 2.0)
                  : null,
              boxShadow: showGlow
                  ? [
                      BoxShadow(
                        color: widget.errorBorderColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
