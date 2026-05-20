import 'package:animation_types/widget/page_snap_toggle.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class WavePageViewScreen extends StatefulWidget {
  const WavePageViewScreen({super.key});

  @override
  State<WavePageViewScreen> createState() => _WavePageViewScreenState();
}

class _WavePageViewScreenState extends State<WavePageViewScreen> {
  late final PageController _pageController;
  final int _pageCount = 5;
  bool isPageSnapping = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Wave PageView")),
      body: Column(
        children: [
          PageSnapToggle(
            value: isPageSnapping,
            onChanged: (newValue) {
              setState(() => isPageSnapping = newValue);
              debugPrint('Page snapping: $newValue');
            },
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pageCount,
              padEnds: false,
              pageSnapping: isPageSnapping,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                    }

                    // Wave: vertical offset using sine curve
                    final wave = sin(value * pi) * 30;

                    // Scale for focus
                    final scale = (1 - value.abs() * 0.15).clamp(0.85, 1.0);

                    return Center(
                      child: Transform.translate(
                        offset: Offset(0, wave),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: screenWidth * 0.65,
                            height: screenHeight * 0.45,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors
                                  .primaries[index % Colors.primaries.length],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Page $index",
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
