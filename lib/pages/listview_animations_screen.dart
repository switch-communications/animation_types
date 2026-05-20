import 'dart:ui';

import 'package:animation_types/utils/no_overscroll_indicator.dart';
import 'package:animation_types/utils/utils.dart';
import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// ===========================
/// LIST ITEM ANIMATION TYPES
/// ===========================
enum ListItemAnimationType {
  fade,
  slide,
  scaleFade,
  zDepth,
  overshoot,
  flow,
  parallax,
  lift,
  reveal,
  blurFade,
  elasticSlide,
  bounce,
  staggeredFade,
  scaleUp,
  slideFade,
  fadeParallax,
  liftFade,
  springScale,
  squashStretch,
  opacityFlow,
}

class ListviewAnimationsScreen extends StatefulWidget {
  const ListviewAnimationsScreen({super.key});

  @override
  State<ListviewAnimationsScreen> createState() =>
      _ListviewAnimationsScreenState();
}

class _ListviewAnimationsScreenState extends State<ListviewAnimationsScreen> {
  final MotionProfile profile = MotionProfile();
  bool showList = true;
  Axis direction = Axis.vertical;
  ListItemAnimationType animationType = ListItemAnimationType.fade;
  double itemDelay = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ListView Animations"),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _controls(),
            const Divider(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: showList
                    ? AnimatedListView(
                        key: const ValueKey("list"),
                        profile: profile,
                        animationType: animationType,
                        direction: direction,
                        itemDelay: itemDelay.toInt(),
                      )
                    : const Center(
                        key: ValueKey("empty"),
                        child: Text("List Hidden"),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () => setState(() => showList = !showList),
                child: Text(showList ? "Hide List" : "Show List"),
              ),
              const SizedBox(width: 10),
              DropdownButton<ListItemAnimationType>(
                value: animationType,
                items: ListItemAnimationType.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => setState(() => animationType = v!),
              ),
              const SizedBox(width: 10),
              Switch(
                value: direction == Axis.horizontal,
                onChanged: (v) => setState(
                  () => direction = v ? Axis.horizontal : Axis.vertical,
                ),
              ),
              Text(direction == Axis.horizontal ? "Horizontal" : "Vertical"),
            ],
          ),
          const SizedBox(height: 10),
          _slider(
            "Item Delay (ms)",
            itemDelay,
            10,
            200,
            (v) => setState(() => itemDelay = v),
          ),
          const SizedBox(height: 10),
          _physicsControls(),
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    final divisions = ((max - min) * 1).toInt().clamp(1, 1000);
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Text(value.toStringAsFixed(0)),
      ],
    );
  }

  Widget _physicsControls() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 120, child: Text("Mass")),
            Expanded(
              child: Slider(
                value: profile.mass,
                min: 0.5,
                max: 3.0,
                onChanged: (v) => setState(() => profile.mass = v),
              ),
            ),
            Text(profile.mass.toStringAsFixed(2)),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 120, child: Text("Stiffness")),
            Expanded(
              child: Slider(
                value: profile.stiffness,
                min: 50,
                max: 600,
                onChanged: (v) => setState(() => profile.stiffness = v),
              ),
            ),
            Text(profile.stiffness.toStringAsFixed(0)),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 120, child: Text("Damping")),
            Expanded(
              child: Slider(
                value: profile.damping,
                min: 1,
                max: 40,
                onChanged: (v) => setState(() => profile.damping = v),
              ),
            ),
            Text(profile.damping.toStringAsFixed(0)),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 120, child: Text("Drag")),
            Expanded(
              child: Slider(
                value: profile.drag,
                min: 0.0,
                max: 0.5,
                onChanged: (v) => setState(() => profile.drag = v),
              ),
            ),
            Text(profile.drag.toStringAsFixed(2)),
          ],
        ),
      ],
    );
  }
}

/// ===========================
/// ANIMATED LISTVIEW
/// ===========================
class AnimatedListView extends StatelessWidget {
  final MotionProfile profile;
  final ListItemAnimationType animationType;
  final Axis direction;
  final int itemDelay;

  const AnimatedListView({
    super.key,
    required this.profile,
    required this.animationType,
    required this.direction,
    required this.itemDelay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: direction,
      physics: SpringyScrollPhysics(
        profile: MotionProfile(damping: 20, stiffness: 300),
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return PhysicsAnimatedItem(
          delay: Duration(milliseconds: index * itemDelay),
          profile: profile,
          type: animationType,
          direction: direction,
          child: Card(
            margin: const EdgeInsets.all(12),
            child: SizedBox(
              width: direction == Axis.horizontal ? 220 : null,
              height: 100,
              child: Center(child: Text("Item $index")),
            ),
          ),
        );
      },
    );
  }
}

class PhysicsAnimatedItem extends StatefulWidget {
  final Widget child;
  final MotionProfile profile;
  final Duration delay;
  final ListItemAnimationType type;
  final Axis direction;

  const PhysicsAnimatedItem({
    super.key,
    required this.child,
    required this.profile,
    required this.type,
    required this.direction,
    this.delay = Duration.zero,
  });

  @override
  State<PhysicsAnimatedItem> createState() => _PhysicsAnimatedItemState();
}

class _PhysicsAnimatedItemState extends State<PhysicsAnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController.unbounded(vsync: this);
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(widget.delay);
    if (!mounted) return;
    controller.value = 0;
    controller.animateWith(
      SpringSimulation(widget.profile.spring, 0, 1, -widget.profile.drag),
    );
  }

  @override
  void didUpdateWidget(covariant PhysicsAnimatedItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (_, child) {
        final v = controller.value.clamp(0.0, 1.0);
        return _buildAnimation(v, child!);
      },
    );
  }

  Widget _buildAnimation(double v, Widget child) {
    switch (widget.type) {
      case ListItemAnimationType.fade:
        return Opacity(opacity: v, child: child);

      case ListItemAnimationType.slide:
        final offset = widget.direction == Axis.vertical
            ? Offset(0, (1 - v) * 120)
            : Offset((1 - v) * 120, 0);
        return Transform.translate(offset: offset, child: child);

      case ListItemAnimationType.scaleFade:
        return Transform.scale(
          scale: 0.7 + 0.3 * v,
          child: Opacity(opacity: v, child: child),
        );

      case ListItemAnimationType.zDepth:
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002) // perspective
            ..scale(0.7 + 0.3 * v)
            ..rotateX((1 - v) * 0.3),
          child: Opacity(opacity: v, child: child),
        );

      case ListItemAnimationType.overshoot:
        return Transform.scale(
          scale: 0.5 + 0.5 * v + 0.2 * v * v,
          child: child,
        );

      case ListItemAnimationType.flow:
        return Transform.translate(
          offset: Offset((1 - v) * 150, 0),
          child: Opacity(opacity: v, child: child),
        );

      case ListItemAnimationType.parallax:
        return Transform.translate(
          offset: Offset(0, (1 - v) * 150),
          child: Opacity(opacity: v, child: child),
        );

      case ListItemAnimationType.lift:
        return Transform.translate(
          offset: Offset(0, (1 - v) * 80),
          child: Transform.scale(
            scale: 0.8 + 0.2 * v,
            child: Opacity(opacity: v, child: child),
          ),
        );

      case ListItemAnimationType.reveal:
        return ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: v,
            child: Opacity(opacity: v, child: child),
          ),
        );

      case ListItemAnimationType.blurFade:
        return Opacity(
          opacity: v,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: (1 - v) * 12,
              sigmaY: (1 - v) * 12,
            ),
            child: child,
          ),
        );

      case ListItemAnimationType.elasticSlide:
        return Transform.translate(
          offset: Offset(0, (1 - v) * 120),
          child: Opacity(opacity: v, child: child),
        );

      case ListItemAnimationType.bounce:
        return Transform.translate(
          offset: Offset(0, (1 - v) * 180),
          child: Transform.scale(
            scale: 0.6 + 0.4 * v,
            child: Opacity(opacity: v, child: child),
          ),
        );

      case ListItemAnimationType.staggeredFade:
        return Opacity(opacity: v, child: child);

      case ListItemAnimationType.scaleUp:
        return Transform.scale(
          scale: 0.6 + 0.4 * v,
          child: Opacity(opacity: v, child: child),
        );

      case ListItemAnimationType.slideFade:
        return Transform.translate(
          offset: Offset(0, (1 - v) * 120),
          child: Opacity(opacity: v, child: child),
        );

      case ListItemAnimationType.fadeParallax:
        return Transform.translate(
          offset: Offset(0, (1 - v) * 150),
          child: Opacity(opacity: v, child: child),
        );

      case ListItemAnimationType.liftFade:
        return Transform.translate(
          offset: Offset(0, (1 - v) * 100),
          child: Transform.scale(
            scale: 0.75 + 0.25 * v,
            child: Opacity(opacity: v, child: child),
          ),
        );

      case ListItemAnimationType.springScale:
        return Transform.scale(
          scale: 0.6 + 0.4 * v,
          child: Opacity(opacity: v, child: child),
        );

      case ListItemAnimationType.squashStretch:
        return Transform.scale(
          scale: 0.5 + 0.5 * v,
          child: Opacity(opacity: v, child: child),
        );

      case ListItemAnimationType.opacityFlow:
        return Transform.translate(
          offset: Offset(0, (1 - v) * 150),
          child: Opacity(opacity: v, child: child),
        );
    }
  }
}
