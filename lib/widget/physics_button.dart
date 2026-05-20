
import 'dart:ui';

import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

enum PhysicsButtonStyle {
  scale,
  squash,
  lift,
  tilt,
  pressDepth,
  bounce,
  glow,
  fadeScale,
  slideUp,
}

class PhysicsButton extends StatefulWidget {
  final Widget child;
  final MotionProfile profile;
  final PhysicsButtonStyle style;
  final VoidCallback? onTap;

  const PhysicsButton({
    super.key,
    required this.child,
    required this.profile,
    required this.style,
    this.onTap,
  });

  @override
  State<PhysicsButton> createState() => PhysicsButtonState();
}

class PhysicsButtonState extends State<PhysicsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, value: 1);
  }

  void _animate({double velocity = 0}) {
    final v = velocity * (1.0 - widget.profile.drag);

    final simulation = SpringSimulation(
      widget.profile.spring,
      _controller.value,
      _controller.value == 1 ? 0 : 1,
      v,
    );

    _controller.animateWith(simulation);
  }

  /// Force replay animation (used when switching styles)
  void replay() {
    _controller.value = 0;
    _controller.animateWith(
      SpringSimulation(widget.profile.spring, 0, 1, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animate(),
      onTapUp: (_) {
        _animate();
        widget.onTap?.call();
      },
      onTapCancel: () => _animate(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final t = _controller.value;
          Widget result = child!;

          // New scale range
          const double minScale = 0.7;
          const double maxScale = 1.0;

          switch (widget.style) {
            case PhysicsButtonStyle.scale:
              result = Transform.scale(
                scale: lerpDouble(minScale, maxScale, t)!,
                child: result,
              );
              break;

            case PhysicsButtonStyle.squash:
              result = Transform.scale(
                scaleX: lerpDouble(0.95, 1.0, t)!,
                scaleY: lerpDouble(minScale, maxScale, t)!,
                child: result,
              );
              break;

            case PhysicsButtonStyle.lift:
              result = Transform.translate(
                offset: Offset(0, lerpDouble(8, 0, t)!),
                child: Transform.scale(
                  scale: lerpDouble(minScale, maxScale, t)!,
                  child: result,
                ),
              );
              break;

            case PhysicsButtonStyle.tilt:
              result = Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(lerpDouble(0.08, 0, t)!),
                child: Transform.scale(
                  scale: lerpDouble(minScale, maxScale, t)!,
                  child: result,
                ),
              );
              break;

            case PhysicsButtonStyle.pressDepth:
              result = Transform.translate(
                offset: Offset(0, lerpDouble(0, 6, 1 - t)!),
                child: Transform.scale(
                  scale: lerpDouble(minScale, maxScale, 1 - t)!,
                  child: result,
                ),
              );
              break;

            case PhysicsButtonStyle.bounce:
              final bounce = Curves.easeOutBack.transform(t);
              result = Transform.scale(
                scale: lerpDouble(minScale, maxScale, bounce)!,
                child: result,
              );
              break;

            case PhysicsButtonStyle.glow:
              result = DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4 * (1 - t)),
                      blurRadius: lerpDouble(20, 0, t)!,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: lerpDouble(minScale, maxScale, t)!,
                  child: result,
                ),
              );
              break;

            case PhysicsButtonStyle.fadeScale:
              result = Opacity(
                opacity: lerpDouble(0.6, 1.0, t)!,
                child: Transform.scale(
                  scale: lerpDouble(minScale, maxScale, t)!,
                  child: result,
                ),
              );
              break;

            case PhysicsButtonStyle.slideUp:
              result = Transform.translate(
                offset: Offset(0, lerpDouble(20, 0, t)!),
                child: Transform.scale(
                  scale: lerpDouble(minScale, maxScale, t)!,
                  child: result,
                ),
              );
              break;
          }

          return result;
        },
        child: widget.child,
      )
      ,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

