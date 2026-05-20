import 'dart:ui';
import 'package:animation_types/widget/page_snap_toggle.dart';
import 'package:flutter/material.dart';

class ZoomFadePageViewScreen extends StatefulWidget {
  const ZoomFadePageViewScreen({super.key});

  @override
  State<ZoomFadePageViewScreen> createState() =>
      _ZoomFadePageViewScreenState();
}

class _ZoomFadePageViewScreenState extends State<ZoomFadePageViewScreen> {
  late final PageController _pageController;
  final int _pageCount = 5;
  bool isPageSnapping = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7);
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
      appBar: AppBar(title: const Text("Zoom & Fade Carousel")),
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
                    double pageOffset = 0.0;
                    if (_pageController.hasClients && _pageController.position.haveDimensions) {
                      pageOffset = _pageController.page! - index;
                    }

                    final t = pageOffset.abs().clamp(0.0, 1.0);
                    final spring = Curves.easeOutBack.transform(1 - t);

                    final scale = lerpDouble(0.8, 1.0, spring)!.clamp(0.0, 1.0);
                    final opacity = lerpDouble(0.5, 1.0, spring)!.clamp(0.0, 1.0);
                    final horizontalMargin = lerpDouble(20, 8, spring)!;
                    final elevation = 10 * spring;

                    return Center(
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.65,
                            height: MediaQuery.of(context).size.height * 0.45,
                            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                            decoration: BoxDecoration(
                              color: Colors.primaries[index % Colors.primaries.length],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: elevation,
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
