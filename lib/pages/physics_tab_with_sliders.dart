import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class PhysicsTabsWithSliders extends StatefulWidget {
  const PhysicsTabsWithSliders({super.key});

  @override
  State<PhysicsTabsWithSliders> createState() => _PhysicsTabsWithSlidersState();
}

class _PhysicsTabsWithSlidersState extends State<PhysicsTabsWithSliders>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  MotionProfile profile = MotionProfile();

  late AnimationController _controller;
  double _currentPosition = 0;

  final List<String> tabs = ["Premium", "Pro", "VIP"];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(() {
      setState(() {
        _currentPosition = _controller.value;
      });
    });
  }

  void _animateTo(int index) {
    final spring = SpringSimulation(
      profile.spring,
      _currentPosition,
      index.toDouble(),
      0,
    );
    _controller.animateWith(spring);
    selectedIndex = index;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTab(int index) {
    double distance = (_currentPosition - index).abs();
    double scale = 1.0 + 0.2 * (1 - distance.clamp(0.0, 1.0));

    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _animateTo(index),
      child: Transform.scale(
        scale: scale,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.deepPurple),
          ),
          child: Text(
            tabs[index],
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Physics Tabs"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          PhysicsControls(
            profile: profile,
            onChanged: () {
              setState(() {}); // Update spring parameters live
            },
          ),
          _buildUnderlineTabs(),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                "Content for ${tabs[selectedIndex]}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnderlineTabs() {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            tabs.length,
            (index) => GestureDetector(
              onTap: () => _animateTo(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: selectedIndex == index
                        ? Colors.deepPurple
                        : Colors.grey[500],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Moving underline
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              double screenWidth = MediaQuery.of(context).size.width;
              double tabWidth = 120; // approximate width per tab
              double left =
                  _currentPosition * tabWidth +
                  (screenWidth - tabWidth * tabs.length) / 2;
              return Transform.translate(
                offset: Offset(left, 0),
                child: Container(
                  width: tabWidth,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
