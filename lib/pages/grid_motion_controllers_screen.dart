import 'dart:math' as math;

import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class MotionMotionControllersScreen extends StatefulWidget {
  const MotionMotionControllersScreen({super.key});

  @override
  State<MotionMotionControllersScreen> createState() => _MotionHomeScreenState();
}

class _MotionHomeScreenState extends State<MotionMotionControllersScreen> {
  bool showGrid = false;
  final MotionProfile profile = MotionProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Physics Grid Motion"),
      ),
      body: SafeArea(child:
      Column(
        children: [
          PhysicsControls(profile: profile, onChanged: () => setState(() {})),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() => showGrid = !showGrid);
            },
            child: Text(showGrid ? "Hide Grid" : "Show Grid"),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: showGrid
                  ? PhysicsGrid(profile: profile)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),)
    );
  }

}

class PhysicsGrid extends StatelessWidget {
  final MotionProfile profile;

  const PhysicsGrid({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return PhysicsGridItem(
          index: index,
          profile: profile,
        );
      },
    );
  }
}

class PhysicsGridItem extends StatefulWidget {
  final int index;
  final MotionProfile profile;

  const PhysicsGridItem({
    super.key,
    required this.index,
    required this.profile,
  });

  @override
  State<PhysicsGridItem> createState() => _PhysicsGridItemState();
}

class _PhysicsGridItemState extends State<PhysicsGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  double lagX = 0;
  double lagY = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController.unbounded(vsync: this);

    Future.delayed(
      Duration(milliseconds: widget.index * 26),
      start,
    );
  }

  void start() {
    controller.animateWith(
      SpringSimulation(
        widget.profile.spring,
        0.0,
        1.0,
        -0.45, // pre-energy
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int column = widget.index % 3;
    final double baseX = (column - 1) * 22;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value.clamp(0.0, 1.2);

        // Target motion
        final targetY = (1 - t) * 42;
        final targetX = math.pow(1 - t, 2).toDouble() * baseX;

        // --- DRAG LAG ---
        lagX += (targetX - lagX) * (1 - widget.profile.drag);
        lagY += (targetY - lagY) * (1 - widget.profile.drag);

        // --- DIRECTIONAL COMPRESSION ---
        final velocityY = targetY - lagY;
        final compression = velocityY.abs().clamp(0, 8);

        final scaleY = 1 - compression * 0.015;
        final scaleX = 1 + compression * 0.012;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(lagX, lagY)
            ..scale(scaleX, scaleY),
          child: _card(),
        );
      },
    );
  }

  Widget _card() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        "Item ${widget.index}",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}