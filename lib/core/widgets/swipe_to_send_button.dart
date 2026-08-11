import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class SwipeToSendButton extends StatefulWidget {
  final String text;
  final VoidCallback onCompleted;
  final Color? backgroundColor;

  const SwipeToSendButton({
    super.key,
    required this.text,
    required this.onCompleted,
    this.backgroundColor,
  });

  @override
  State<SwipeToSendButton> createState() => _SwipeToSendButtonState();
}

class _SwipeToSendButtonState extends State<SwipeToSendButton> with SingleTickerProviderStateMixin {
  double _position = 0.0;
  bool _isCompleted = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isCompleted) return;

    setState(() {
      _position += details.delta.dx;
      if (_position < 0) _position = 0;
      if (_position > maxWidth - 64) {
        _position = maxWidth - 64;
      }
    });
  }

  void _onDragEnd(DragEndDetails details, double maxWidth) {
    if (_isCompleted) return;

    if (_position > (maxWidth - 64) * 0.8) {
      // Completed
      setState(() {
        _position = maxWidth - 64;
        _isCompleted = true;
      });
      HapticFeedback.mediumImpact();
      widget.onCompleted();
    } else {
      // Return to start
      _animation = Tween<double>(begin: _position, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      )..addListener(() {
          setState(() {
            _position = _animation.value;
          });
        });
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        
        return Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryTeal,
                AppColors.primaryCoral.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Placeholder Text
              Center(
                child: Opacity(
                  opacity: 1.0 - (_position / (maxWidth - 64)),
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Handle
              Positioned(
                left: _position + 4,
                top: 4,
                bottom: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _onDragUpdate(details, maxWidth),
                  onHorizontalDragEnd: (details) => _onDragEnd(details, maxWidth),
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isCompleted ? Icons.check : Icons.arrow_forward,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
