import 'dart:math' as math;

import 'package:flutter/material.dart';

enum GridMotionStyle { calm, energetic, playful }

class MotionStyleGrid extends StatefulWidget {
  const MotionStyleGrid({super.key});

  @override
  State<MotionStyleGrid> createState() => _MotionStyleGridState();
}

class _MotionStyleGridState extends State<MotionStyleGrid>
    with SingleTickerProviderStateMixin {
  GridMotionStyle style = GridMotionStyle.calm;
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  void changeStyle(GridMotionStyle newStyle) {
    setState(() {
      style = newStyle;
      controller.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:  Scaffold(
      appBar: AppBar(title: const Text("2D Motion Styles")),
      body: SafeArea(child:
      Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btn("Calm", GridMotionStyle.calm),
              _btn("Energetic", GridMotionStyle.energetic),
              _btn("Playful", GridMotionStyle.playful),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final row = index ~/ 2;
                final col = index % 2;

                final delay = (row + col) * 0.08;
                final animation = CurvedAnimation(
                  parent: controller,
                  curve: Interval(delay, 1, curve: Curves.linear),
                );

                return AnimatedBuilder(
                  animation: animation,
                  builder: (_, child) {
                    return _buildMotion(
                      t: animation.value,
                      index: index,
                      child: child!,
                    );
                  },
                  child: _GridItem(index),
                );
              },
            ),
          ),
        ],
      ),)
    ),);
  }

  Widget _buildMotion({
    required double t,
    required int index,
    required Widget child,
  }) {
    late double slide;
    late double squash;
    late double jiggle;
    late double rotation;

    switch (style) {
      case GridMotionStyle.calm:
        slide = 60 * (1 - Curves.easeOutCubic.transform(t));
        squash = 0.02 * math.sin(t * math.pi);
        jiggle = 0;
        rotation = 0.02 * (1 - t);
        break;

      case GridMotionStyle.energetic:
        slide = 80 * (1 - Curves.easeOutBack.transform(t));
        squash = 0.06 * math.sin(t * math.pi);
        jiggle = 0.02 * math.sin(t * math.pi * 4) * (1 - t);
        rotation = 0.05 * (1 - t);
        break;

      case GridMotionStyle.playful:
        slide = 70 * (1 - Curves.easeOut.transform(t));
        squash = 0.08 * math.sin(t * math.pi);
        jiggle = 0.04 * math.sin(t * math.pi * 6) * (1 - t);
        rotation = 0.08 * math.sin(t * math.pi * 2) * (1 - t);
        break;
    }

    return Transform.translate(
      offset: Offset(0, slide),
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scaleX: 1 + squash,
          scaleY: 1 - squash,
          child: Transform.scale(
            scale: 1 + jiggle,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _btn(String text, GridMotionStyle s) {
    return ElevatedButton(
      onPressed: () => changeStyle(s),
      child: Text(text),
    );
  }
}

class _GridItem extends StatelessWidget {
  final int index;
  const _GridItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        "Item $index",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}