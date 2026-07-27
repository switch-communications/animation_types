import 'dart:ui';
import 'package:flutter/material.dart';

class SvgPathAnimationWidget extends StatefulWidget {
  const SvgPathAnimationWidget({Key? key}) : super(key: key);

  @override
  State<SvgPathAnimationWidget> createState() => _SvgPathAnimationWidgetState();
}

class _SvgPathAnimationWidgetState extends State<SvgPathAnimationWidget>
    with TickerProviderStateMixin {
  static const double originalWidth = 401.0;
  static const double originalHeight = 476.0;

  double svgWidth = 300.0;
  double svgHeight = 300.0;

  // 🎯 VERTICAL PADDING: Shifts the path down so max-scaled cards (300px) don't clip
  static const double topPadding = 100.0;

  late AnimationController _controller;
  bool isPlaying = false;
  bool isAnimationFinished = false;

  static const int totalCards = 10;
  static const double cardPadding = 0.0; // Edge-to-edge
  static const double initialCardSize = 100.0;
  static const double targetCardSize = 300.0;

  late AnimationController _spacingController;
  late Animation<double> _spacingAnimation;



  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalCards * 600),
    );

    _spacingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _spacingAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _spacingController, curve: Curves.easeOutBack),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isPlaying = false;
          isAnimationFinished = true;
        });
        _spacingController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _spacingController.dispose();
    super.dispose();
  }

  Path buildSvgPath(Size targetSize) {
    if (targetSize.width <= 0 || targetSize.height <= 0) return Path();

    final double sx = targetSize.width / originalWidth;
    final double sy = targetSize.height / originalHeight;

    final Path path = Path();
    path.moveTo(398.093 * sx, 5.92949 * sy);

    path.cubicTo(
      398.093 * sx,
      5.92949 * sy,
      202.102 * sx,
      0.0232354 * sy,
      131.104 * sx,
      3.71257 * sy,
    );
    path.cubicTo(
      60.1068 * sx,
      7.40191 * sy,
      28.8942 * sx,
      42.0827 * sy,
      11.2385 * sx,
      101.04 * sy,
    );
    path.cubicTo(
      2.9303 * sx,
      128.783 * sy,
      4.45327 * sx,
      163.097 * sy,
      2.53076 * sx,
      208.618 * sy,
    );
    path.cubicTo(
      2.53076 * sx,
      208.618 * sy,
      2.53996 * sx,
      312.827 * sy,
      2.53076 * sx,
      312.827 * sy,
    );
    path.cubicTo(
      3.36285 * sx,
      380.783 * sy,
      17.3629 * sx,
      408.923 * sy,
      43.4907 * sx,
      437.803 * sy,
    );
    path.cubicTo(
      63.9296 * sx,
      456.255 * sy,
      91.796 * sx,
      475.071 * sy,
      132.685 * sx,
      472.97 * sy,
    );
    path.cubicTo(
      173.574 * sx,
      470.869 * sy,
      209.581 * sx,
      449.161 * sy,
      232.879 * sx,
      411.473 * sy,
    );
    path.cubicTo(
      256.177 * sx,
      373.785 * sy,
      247.924 * sx,
      335.512 * sy,
      249.464 * sx,
      269.968 * sy,
    );
    path.cubicTo(
      249.464 * sx,
      207.515 * sy,
      249.464 * sx,
      217.878 * sy,
      249.464 * sx,
      217.878 * sy,
    );

    return path.shift(const Offset(0, topPadding));
  }

  void _toggleAnimation() {
    if (_controller.isAnimating) {
      _controller.stop();
      setState(() => isPlaying = false);
    } else {
      if (_controller.status == AnimationStatus.completed) {
        _controller.reset();
        _spacingController.reset();
        setState(() => isAnimationFinished = false);
      }
      _controller.forward();
      setState(() => isPlaying = true);
    }
  }

  double _getCardSizeForDistance(
      double currentDistance,
      double targetStopPoint,
      ) {
    if (targetStopPoint <= 0) return initialCardSize;

    final double normalized = (currentDistance / targetStopPoint).clamp(
      0.0,
      1.0,
    );

    if (normalized < 0.4) {
      return initialCardSize;
    } else {
      final double t = (normalized - 0.4) / 0.6;
      return lerpDouble(initialCardSize, targetCardSize, t) ?? initialCardSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Path path = buildSvgPath(Size(svgWidth, svgHeight));
    final List<PathMetric> metricsList = path.computeMetrics().toList();
    final PathMetric? metric = metricsList.isNotEmpty
        ? metricsList.first
        : null;
    final double pathLength = metric?.length ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('More Topics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleAnimation,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(
                    isPlaying
                        ? 'Pause'
                        : isAnimationFinished
                        ? 'Replay'
                        : 'Play',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                physics: isAnimationFinished
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_controller, _spacingController]),
                  builder: (context, child) {
                    final double animationProgress = _controller.value;
                    final double targetStopPoint = pathLength * 0.90;

                    const double initialTrainLength =
                        (totalCards - 1) * initialCardSize;
                    const double finalTrainLength =
                        (totalCards - 1) * targetCardSize;

                    final double startRequiredLeaderDistance =
                        targetStopPoint + initialTrainLength;
                    final double endRequiredLeaderDistance =
                        targetStopPoint + finalTrainLength;

                    final double leaderDistance =
                        animationProgress *
                            lerpDouble(
                              startRequiredLeaderDistance,
                              endRequiredLeaderDistance,
                              animationProgress,
                            )!;

                    final List<double> cardDistances = List.filled(
                      totalCards,
                      0.0,
                    );
                    final List<double> cardSizes = List.filled(
                      totalCards,
                      initialCardSize,
                    );
                    final List<Offset> cardPositions = List.filled(
                      totalCards,
                      Offset.zero,
                    );

                    // 🎯 EXACT DISTANCE AND SIZE ACCUMULATION (ELIMINATES GAPS)
                    for (int i = 0; i < totalCards; i++) {
                      if (i == 0) {
                        cardDistances[0] = leaderDistance;
                      } else {
                        // Self-consistent distance/size solve — NO spacing here
                        double solvedDist = cardDistances[i - 1];
                        for (int iter = 0; iter < 6; iter++) {
                          final double sizeGuess = _getCardSizeForDistance(
                            solvedDist,
                            targetStopPoint,
                          );
                          final double prevRadius = cardSizes[i - 1] / 2.0;
                          final double currentRadius = sizeGuess / 2.0;
                          final double requiredGap =
                              prevRadius + currentRadius + cardPadding;

                          solvedDist = cardDistances[i - 1] - requiredGap;
                        }

                        cardDistances[i] = solvedDist;
                      }

                      final double dist = cardDistances[i];
                      cardSizes[i] = _getCardSizeForDistance(
                        dist,
                        targetStopPoint,
                      );

                      if (dist <= 0) {
                        final Tangent? startTangent = metric
                            ?.getTangentForOffset(pathLength);
                        cardPositions[i] =
                            startTangent?.position ?? Offset.zero;
                      } else if (dist <= pathLength) {
                        final double metricOffset = (pathLength - dist).clamp(
                          0.0,
                          pathLength,
                        );
                        final Tangent? tangent = metric?.getTangentForOffset(
                          metricOffset,
                        );
                        cardPositions[i] = tangent?.position ?? Offset.zero;
                      } else {
                        // 🎯 SEAMLESS OFF-PATH EXTENSION
                        final Tangent? endTangent = metric?.getTangentForOffset(0);
                        final Offset endPos = endTangent?.position ?? Offset(svgWidth, svgHeight);
                        final double extraDist = dist - pathLength;

                        cardPositions[i] = Offset(
                          endPos.dx + extraDist,
                          endPos.dy,
                        );
                      }
                    }

                    final double maxCardX = cardPositions
                        .map((p) => p.dx)
                        .fold(svgWidth, (a, b) => a > b ? a : b);
                    final double containerWidth = maxCardX + targetCardSize;

                    return SizedBox(
                      width: containerWidth,
                      height: svgHeight + topPadding + 200.0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // if (!isAnimationFinished)
                          //   CustomPaint(
                          //     size: Size(svgWidth, svgHeight + topPadding),
                          //     painter: PathPainter(path: path),
                          //   ),
                          ...List.generate(totalCards, (index) {
                            final double dist = cardDistances[index];
                            if (dist <= 0) return const SizedBox.shrink();

                            final double renderedSize = cardSizes[index];
                            final Offset pos = cardPositions[index];

                            final double extraSpacing =
                                (totalCards - 1 - index) * _spacingAnimation.value;

                            final double leftOffset =
                                pos.dx - (renderedSize / 2) + extraSpacing;
                            final double topOffset =
                                pos.dy - (renderedSize / 2);

                            final double maxExtraSpacing =
                                (totalCards - 1) * _spacingAnimation.value;
                            final double containerWidth =
                                maxCardX + targetCardSize + maxExtraSpacing;

                            return Positioned(
                              left: leftOffset,
                              top: topOffset,
                              child: Container(
                                width: renderedSize,
                                height: renderedSize,
                                decoration: BoxDecoration(
                                  color: Colors
                                      .indigo[(index + 1) * 100 % 900 + 100],
                                  borderRadius: BorderRadius.circular(
                                    12 * (renderedSize / 100.0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Card #${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14 * (renderedSize / 100.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class PathPainter extends CustomPainter {
//   final Path path;
//
//   PathPainter({required this.path});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = const Color(0xFFFF0000)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4.0
//       ..strokeCap = StrokeCap.round;
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant PathPainter oldDelegate) =>
//       oldDelegate.path != path;
// }