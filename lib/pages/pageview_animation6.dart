import 'dart:ui';

import 'package:animation_types/widget/page_snap_toggle.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CurvedCarouselPageView extends StatefulWidget {
  const CurvedCarouselPageView({super.key});

  @override
  State<CurvedCarouselPageView> createState() => _CurvedCarouselPageViewState();
}

class _CurvedCarouselPageViewState extends State<CurvedCarouselPageView> {
  late final PageController _pageController;
  final int _pageCount = 7;
  bool isPageSnapping = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.6);
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Curved / Circular Scroll Path")),
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
                    double pageValue = 0.0;
                    if (_pageController.hasClients &&
                        _pageController.position.haveDimensions) {
                      pageValue = _pageController.page! - index;
                    }

                    final t = pageValue.abs().clamp(0.0, 1.0);
                    final spring = Curves.easeOutBack.transform(1 - t);
                    final scale = lerpDouble(0.8, 1.0, spring)!;
                    final arcRadius = 50.0;
                    final verticalOffset = -sin(pageValue * pi / 2) * arcRadius;
                    final rotationY = pageValue * 0.25;
                    final horizontalMargin = lerpDouble(20, 8, spring)!;
                    final blur = 12 * spring;
                    final offsetY = 6 * spring;

                    return Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(0.0, verticalOffset)
                          ..rotateY(rotationY)
                          ..scale(scale),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.55,
                          height: MediaQuery.of(context).size.height * 0.45,
                          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                Colors.primaries[index % Colors.primaries.length],
                                Colors.primaries[(index + 2) % Colors.primaries.length],
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: blur,
                                offset: Offset(0, offsetY),
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
