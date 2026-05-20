import 'dart:ui';

import 'package:animation_types/widget/page_snap_toggle.dart';
import 'package:flutter/material.dart';

class VerticalParallaxPageView extends StatefulWidget {
  const VerticalParallaxPageView({super.key});

  @override
  State<VerticalParallaxPageView> createState() =>
      _VerticalParallaxPageViewState();
}

class _VerticalParallaxPageViewState extends State<VerticalParallaxPageView> {
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
      appBar: AppBar(title: const Text("Vertical Parallax")),
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

                    final verticalOffset = value * 60; // vertical movement
                    final t = value.abs().clamp(0.0, 1.0);
                    final spring = Curves.easeOutBack.transform(1 - t);

                    final scale = lerpDouble(0.85, 1.0, spring)!;
                    final horizontalGap = lerpDouble(20, 4, spring)!;

                    return Center(
                      child: Transform.translate(
                        offset: Offset(0, verticalOffset),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: screenWidth * 0.65,
                            height: screenHeight * 0.5,
                            margin:  EdgeInsets.symmetric(horizontal: horizontalGap),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.primaries[index %
                                      Colors.primaries.length],
                                  Colors.primaries[(index + 3) %
                                      Colors.primaries.length],
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
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
