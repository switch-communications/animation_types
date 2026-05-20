import 'dart:math' as math;

import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// ---------------------- Home Screen ----------------------
class GridZAxisScreen extends StatefulWidget {
  const GridZAxisScreen({super.key});

  @override
  State<GridZAxisScreen> createState() => _MotionHomeScreenState();
}

class _MotionHomeScreenState extends State<GridZAxisScreen> {
  bool showGrid = false;
  final MotionProfile profile = MotionProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Z-Axis Flow Grid")),
      body: SafeArea(child:
      Column(
        children: [
          PhysicsControls(profile: profile, onChanged: () => setState(() {})),
          ElevatedButton(
            onPressed: () => setState(() => showGrid = !showGrid),
            child: Text(showGrid ? "Hide Grid" : "Show Grid"),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showGrid
                  ? ZAxisGrid(profile: profile)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),)
    );
  }
}


/// ---------------------- Z-Axis Grid ----------------------
class ZAxisGrid extends StatelessWidget {
  final MotionProfile profile;
  final int crossAxisCount;

  const ZAxisGrid({super.key, required this.profile, this.crossAxisCount = 3});

  @override
  Widget build(BuildContext context) {
    final itemCount = 9;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return ZAxisGridItem(index: index, profile: profile);
      },
    );
  }
}

/// ---------------------- Z-Axis Grid Item ----------------------
class ZAxisGridItem extends StatefulWidget {
  final int index;
  final MotionProfile profile;

  const ZAxisGridItem({super.key, required this.index, required this.profile});

  @override
  State<ZAxisGridItem> createState() => _ZAxisGridItemState();
}

class _ZAxisGridItemState extends State<ZAxisGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  double scale = 0;
  double rotation = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController.unbounded(vsync: this);

    // Stagger delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 80), start);
  }

  void start() {
    controller.animateWith(
      SpringSimulation(widget.profile.spring, 0, 1, -0.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value.clamp(0.0, 1.2);

        // Lagged smooth scale
        scale += (t - scale) * (1 - widget.profile.drag);

        // Squash & stretch
        final compression = (scale * 10).clamp(0, 5);
        final scaleX = scale + compression * 0.02;
        final scaleY = scale - compression * 0.015;

        // Rotation
        rotation = (0.05 - 0.1 * (1 - scale)) * math.sin(scale * math.pi);

        // Z-axis illusion with perspective
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..scale(0.3 + 0.7 * scale + scaleX * 0.1, 0.3 + 0.7 * scale + scaleY * 0.1)
          ..rotateZ(rotation);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}