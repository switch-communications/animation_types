import 'package:animation_types/widget/physics_button.dart';
import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/material.dart';

class PhysicsButtonPlayground extends StatefulWidget {
  const PhysicsButtonPlayground({super.key});

  @override
  State<PhysicsButtonPlayground> createState() =>
      _PhysicsButtonPlaygroundState();
}

class _PhysicsButtonPlaygroundState extends State<PhysicsButtonPlayground> {
  final MotionProfile profile = MotionProfile();

  PhysicsButtonStyle selectedStyle = PhysicsButtonStyle.scale;

  final GlobalKey<PhysicsButtonState> buttonKey =
      GlobalKey<PhysicsButtonState>();

  Widget _button() {
    return GestureDetector(
      onTap: () {
        // Replay animation on style change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          buttonKey.currentState?.replay();
        });
      },
      child: Container(
        width: 260,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          selectedStyle.name.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Physics Button Playground")),
      body: SafeArea(child:
      Column(
        children: [
          /// Button Preview
          Expanded(
            child: Center(
              child: PhysicsButton(
                key: buttonKey,
                profile: profile,
                style: selectedStyle,
                child: _button(),
              ),
            ),
          ),

          const Divider(height: 1),

          /// Style selector
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: PhysicsButtonStyle.values.map((style) {
                return RadioListTile<PhysicsButtonStyle>(
                  title: Text(style.name),
                  value: style,
                  groupValue: selectedStyle,
                  onChanged: (value) {
                    setState(() {
                      selectedStyle = value!;
                    });

                    // Replay animation on style change
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      buttonKey.currentState?.replay();
                    });
                  },
                );
              }).toList(),
            ),
          ),

          /// Physics sliders
          PhysicsControls(profile: profile, onChanged: () => setState(() {})),
        ],
      ),)
    );
  }
}
