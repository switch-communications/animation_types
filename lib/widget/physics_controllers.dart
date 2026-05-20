import 'package:flutter/material.dart';

class MotionProfile {
  double mass;
  double stiffness;
  double damping;
  double drag;

  MotionProfile({
    this.mass = 1.25,
    this.stiffness = 300,
    this.damping = 10,
    this.drag = 0.15,
  });

  SpringDescription get spring => SpringDescription(
    mass: mass,
    stiffness: stiffness,
    damping: damping,
  );

  Duration get dynamicDuration {
    double ms = (mass * 1000) / (stiffness / 100);
    return Duration(milliseconds: ms.toInt().clamp(100, 2000));
  }

  Curve get dynamicCurve {
    if (damping < 12) return Curves.elasticOut; // Bouncy
    if (damping < 25) return Curves.easeOutBack; // Overshoot
    return Curves.easeOutQuart; // Smooth
  }
}


class PhysicsControls extends StatelessWidget {
  final MotionProfile profile;
  final VoidCallback onChanged;

  const PhysicsControls({
    super.key,
    required this.profile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _slider(
            label: "Mass",
            value: profile.mass,
            min: 0.5,
            max: 3.0,
            onChanged: (v) {
              profile.mass = v;
              onChanged();
            },
          ),
          _slider(
            label: "Stiffness",
            value: profile.stiffness,
            min: 50,
            max: 600,
            onChanged: (v) {
              profile.stiffness = v;
              onChanged();
            },
          ),
          _slider(
            label: "Damping",
            value: profile.damping,
            min: 1,
            max: 40,
            onChanged: (v) {
              profile.damping = v;
              onChanged();
            },
          ),
          _slider(
            label: "Drag",
            value: profile.drag,
            min: 0.02,
            max: 0.5,
            onChanged: (v) {
              profile.drag = v;
              onChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toStringAsFixed(2)}"),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}