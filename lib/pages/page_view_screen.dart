import 'dart:ui';

import 'package:animation_types/widget/page_snap_toggle.dart';
import 'package:flutter/material.dart';

class PremiumPageViewScreen extends StatefulWidget {
  const PremiumPageViewScreen({super.key});

  @override
  State<PremiumPageViewScreen> createState() => _PremiumPageViewScreenState();
}

class _PremiumPageViewScreenState extends State<PremiumPageViewScreen> {
  late final PageController _pageController;
  final double _viewportFraction = 0.8;
  final int _pageCount = 5;
  bool isPageSnapping = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
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
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("PageView")),
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
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double pageOffset = 0.0;
                    if (_pageController.position.haveDimensions) {
                      pageOffset = _pageController.page! - index;
                    }

                    final t = pageOffset.abs().clamp(0.0, 1.0);
                    final spring = Curves.easeOutBack.transform(1 - t);
                    final scale = lerpDouble(0.85, 1.0, spring)!;
                    final horizontalMargin = lerpDouble(20, 8, spring)!;
                    final elevation = 10 * spring;

                    return Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: screenWidth * 0.7,
                          height: screenHeight * 0.50,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors
                                .primaries[index % Colors.primaries.length],
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: elevation,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Page $index",
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
