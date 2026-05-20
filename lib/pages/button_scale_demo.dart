import 'dart:ui';

import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class PhysicsScaleDemo extends StatefulWidget {
  const PhysicsScaleDemo({super.key});

  @override
  State<PhysicsScaleDemo> createState() => _PhysicsScaleDemoState();
}

class _PhysicsScaleDemoState extends State<PhysicsScaleDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final MotionProfile profile = MotionProfile();

  static const double minScale = 0.6;
  static const double maxScale = 1.0;

  bool expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, value: 0);
  }

  void animate({double velocity = 0}) {
    final spring = profile.spring;

    /// apply drag to velocity
    final draggedVelocity = velocity * (1.0 - profile.drag);

    final simulation = SpringSimulation(
      spring,
      _controller.value,
      expanded ? 0.0 : 1.0,
      draggedVelocity,
    );

    expanded = !expanded;
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Physics Scale Animation")),
      body: SafeArea(child:
      Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => animate(),
                onVerticalDragEnd: (details) {
                  final velocity =
                      -details.velocity.pixelsPerSecond.dy / 1000;
                  animate(velocity: velocity);
                },
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) {
                    final scale = lerpDouble(
                      minScale,
                      maxScale,
                      _controller.value,
                    )!;
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 300,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "80% → 100%",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),

          PhysicsControls(
            profile: profile,
            onChanged: () => setState(() {}),
          ),
        ],
      ),)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
