import 'package:flutter/material.dart';

class PumpingAnimation extends StatefulWidget {
  @override
  _PumpingAnimationState createState() => _PumpingAnimationState();
}

class _PumpingAnimationState extends State<PumpingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: Container(
            width: _animation.value * 80,
            height: _animation.value * 80,
            child: Image.asset('assets/images/alert.png'),
          ),
        );
      },
    );
  }
}
