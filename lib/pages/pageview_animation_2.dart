import 'package:animation_types/widget/page_snap_toggle.dart';
import 'package:flutter/material.dart';

class PremiumPageViewScreen2 extends StatefulWidget {
  const PremiumPageViewScreen2({super.key});

  @override
  State<PremiumPageViewScreen2> createState() => _PremiumPageViewScreenState();
}

class _PremiumPageViewScreenState extends State<PremiumPageViewScreen2> {
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
      backgroundColor: Colors.grey.shade100,
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
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0.0;

                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                    }

                    // Scale: focused page bigger
                    final scale = (1 - value.abs() * 0.15).clamp(0.85, 1.0);

                    // Rotation: small Y rotation
                    final rotationY = value * 0.25;

                    // Parallax translation
                    final parallax = value * 20;

                    return Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(parallax)
                          ..rotateY(rotationY)
                          ..scale(scale),
                        child: Container(
                          width: screenWidth * 0.65,
                          // smaller than fraction
                          height: screenHeight * 0.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.primaries[index %
                                    Colors.primaries.length],
                                Colors.primaries[(index + 2) %
                                    Colors.primaries.length],
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12 * (1 - value.abs()).clamp(0, 1),
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 20,
                                left: 20 + value * 10, // subtle parallax
                                child: Icon(
                                  Icons.star,
                                  size: 50,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "Page $index",
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
