import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widget/physics_controllers.dart';

// ─── Cubic Bézier (1-D) for smooth separation force ───────────────────────
double _cubicBez(double t, double p1, double p2) {
  // Simplified: endpoints fixed at 0 and 0, only inner handles vary.
  final u = 1 - t;
  return 3 * u * u * t * p1 + 3 * u * t * t * p2;
}

class ShopPillowAnimationPage extends StatefulWidget {
  const ShopPillowAnimationPage({super.key});

  @override
  State<ShopPillowAnimationPage> createState() =>
      _ShopPillowAnimationPageState();
}

class _ShopPillowAnimationPageState extends State<ShopPillowAnimationPage>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  late List<AnimationController> _controllers;
  late List<Animation<double>> _paths;
  late AnimationController _spacingController;
  late Animation<double> _spacingAnimation;

  // ── Spring profile (only mass/stiffness/damping/drag affect duration) ─────
  final MotionProfile _profile = MotionProfile(
    mass: 0.6,
    stiffness: 170.0,
    damping: 25.0,
  );

  // ── Motion params – read live in AnimatedBuilder, never reinit on change ──
  double _angleMultiplier    = 0.5;
  double _separationForce    = 30.0;
  double _separationSpring   = 0.5;   // 0 = gradual arc, 1 = sharp snap
  double _dropDistanceFactor = 0.18;  // fraction of screen height
  double _turnPointOffset    = 0.0;   // px below baseline before curving back

  static const double imageSize = 85.0;

  final List<String> _labels = [
    'A','B','C','D','E','F','G','H','I','J','K','L'
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _buildControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final c in _controllers) c.dispose();
    _spacingController.dispose();
  }

  // ── Build controllers from current _profile duration ─────────────────────
  void _buildControllers() {
    _controllers = List.generate(
      _labels.length,
          (_) => AnimationController(
        vsync: this,
        duration: _profile.dynamicDuration,
      ),
    );
    _paths = _controllers.map((c) =>
        Tween<double>(begin: 0.0, end: 1.0).animate(
          // Linear parent → we apply easing manually in the position math
          // so the drop and horizontal phases can have independent curves.
          CurvedAnimation(parent: c, curve: Curves.linear),
        ),
    ).toList();

    _spacingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _spacingAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _spacingController, curve: Curves.easeOutBack),
    );
  }

  /// Called only on spring-slider *release* (onChangeEnd) — no mid-drag jitter.
  void _reinitControllers() {
    _disposeControllers();
    _buildControllers();
    setState(() {});
  }

  // ── Playback ──────────────────────────────────────────────────────────────
  Future<void> _playAnimation() async {
    final delay =
    (_profile.dynamicDuration.inMilliseconds * 0.25).toInt();
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].forward();
      await Future.delayed(Duration(milliseconds: delay));
    }
    await Future.delayed(_profile.dynamicDuration);
    await _spacingController.forward();
  }

  void _resetAnimation() {
    for (final c in _controllers) c.reset();
    _spacingController.reset();
    setState(() {});
  }

  // ── Easing helpers ────────────────────────────────────────────────────────

  /// Smooth ease-in-out for the horizontal train phase (0→1).
  double _easeHoriz(double t) {
    // easeInOutSine
    return -(math.cos(math.pi * t) - 1) / 2;
  }

  /// Ease-out for the vertical drop phase (0→1).
  double _easeDrop(double t) {
    // easeOutQuad
    return 1 - (1 - t) * (1 - t);
  }

  // ── Position math (called per frame inside AnimatedBuilder) ───────────────
  ({double x, double y}) _cardPosition(
      int i,
      double dropDistance,
      double spacing,
      ) {
    final double rawT = _paths[i].value; // linear 0→1

    // ── Horizontal train ──────────────────────────────────────────────────
    final double stepSize = imageSize + spacing;
    double xShift = 0;
    for (int j = i; j < _labels.length; j++) {
      xShift += _easeHoriz(_paths[j].value);
    }
    double baseX = xShift * stepSize - stepSize;
    if (baseX < 0) baseX = 0;

    // ── Vertical drop ─────────────────────────────────────────────────────
    double currentY = 0;
    double angleX   = 0;
    double sepX     = 0;

    // Drop phase begins at t = 0.4
    if (rawT > 0.4) {
      final double tDrop = _easeDrop((rawT - 0.4) / 0.6);

      if (_turnPointOffset <= 0) {
        // Straight drop to baseline
        currentY = tDrop * dropDistance;
      } else {
        // Arc below baseline then return
        final double peak = dropDistance + _turnPointOffset;
        if (tDrop <= 0.5) {
          currentY = tDrop * 2 * peak;
        } else {
          final double tReturn = (tDrop - 0.5) / 0.5;
          // ease the return leg so it decelerates gently at the baseline
          final double eReturn = 1 - (1 - tReturn) * (1 - tReturn);
          currentY = peak - eReturn * (peak - dropDistance);
        }
      }

      // Angle-based horizontal drift (proportional to Y)
      angleX = currentY * _angleMultiplier;

      // Smooth Bézier separation in the last 20% of the drop phase
      if (rawT > 0.8) {
        final double tSep = (rawT - 0.8) / 0.2;
        // _separationSpring shapes the inner Bézier handles:
        //   low  → gradual bell (handle near midpoint)
        //   high → sharp early peak then slow decay
        final double p1 = _separationSpring * 0.9 + 0.05;
        final double p2 = (1.0 - _separationSpring) * 0.9 + 0.05;
        sepX = _cubicBez(tSep, p1, p2) * _separationForce;
      }
    }

    return (x: baseX - angleX - sepX, y: currentY);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double screenHeight  = MediaQuery.of(context).size.height;
    final double dropDistance  = screenHeight * _dropDistanceFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 40),
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    ..._controllers,
                    _spacingController,
                  ]),
                  builder: (context, _) {
                    final double spacing = _spacingAnimation.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: List.generate(_labels.length, (i) {
                        final pos = _cardPosition(i, dropDistance, spacing);
                        return Positioned(
                          left: pos.x,
                          top:  pos.y,
                          child: _buildCard(i),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
            // ── Buttons ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _playAnimation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Animate',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _showControlsSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0EEFF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: Color(0xFF6C63FF)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet ──────────────────────────────────────────────────────────
  void _showControlsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 1.0,
        snap: true,
        snapSizes: const [0.3, 0.6, 1.0],
        builder: (ctx, scrollController) => StatefulBuilder(
          builder: (ctx, setSheet) {
            // ── Motion sliders: setState only, no reinit ─────────────────
            void liveUpdate(VoidCallback fn) {
              fn();
              setSheet(() {});
              setState(() {});
            }

            // ── Spring sliders: update on release only ───────────────────
            void springRelease(VoidCallback fn) {
              fn();
              setSheet(() {});
              _reinitControllers();
            }

            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.tune_rounded,
                            color: Color(0xFF6C63FF), size: 20),
                        const SizedBox(width: 8),
                        const Text('Physics Controls',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6C63FF))),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () {
                            _resetAnimation();
                            setSheet(() {});
                          },
                          icon: const Icon(Icons.replay, size: 15),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6C63FF),
                            side: const BorderSide(color: Color(0xFF6C63FF)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Scrollable sliders
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      children: [
                        // ── Spring physics (onChangeEnd only) ───────────
                        _section('Spring Physics'),
                        _slider(
                          label: 'Mass',
                          value: _profile.mass,
                          min: 0.5, max: 3.0,
                          // Show value live but only reinit on release
                          onChanged: (v) => setSheet(() => _profile.mass = v),
                          onChangeEnd: (v) => springRelease(() => _profile.mass = v),
                        ),
                        _slider(
                          label: 'Stiffness',
                          value: _profile.stiffness,
                          min: 50, max: 600,
                          onChanged: (v) => setSheet(() => _profile.stiffness = v),
                          onChangeEnd: (v) => springRelease(() => _profile.stiffness = v),
                        ),
                        _slider(
                          label: 'Damping',
                          value: _profile.damping,
                          min: 1, max: 40,
                          onChanged: (v) => setSheet(() => _profile.damping = v),
                          onChangeEnd: (v) => springRelease(() => _profile.damping = v),
                        ),
                        _slider(
                          label: 'Drag',
                          value: _profile.drag,
                          min: 0.02, max: 0.5,
                          onChanged: (v) => setSheet(() => _profile.drag = v),
                          onChangeEnd: (v) => springRelease(() => _profile.drag = v),
                        ),
                        const SizedBox(height: 12),

                        // ── Drop & angle (live, no reinit) ───────────────
                        _section('Drop & Angle'),
                        _slider(
                          label: 'Angle Multiplier',
                          value: _angleMultiplier,
                          min: 0.1, max: 1.0,
                          onChanged: (v) => liveUpdate(() => _angleMultiplier = v),
                        ),
                        _slider(
                          label: 'Drop Distance',
                          value: _dropDistanceFactor,
                          min: 0.12, max: 0.50,
                          display: '${(_dropDistanceFactor * 100).toStringAsFixed(0)}% screen',
                          onChanged: (v) => liveUpdate(() => _dropDistanceFactor = v),
                        ),
                        _slider(
                          label: 'Turn Point Offset',
                          value: _turnPointOffset,
                          min: 0, max: 200,
                          display: '${_turnPointOffset.toStringAsFixed(0)} px below',
                          onChanged: (v) => liveUpdate(() => _turnPointOffset = v),
                        ),
                        const SizedBox(height: 12),

                        // ── Bézier separation (live, no reinit) ──────────
                        _section('Bézier Separation'),
                        _slider(
                          label: 'Separation Force',
                          value: _separationForce,
                          min: 0, max: 200,
                          display: '${_separationForce.toStringAsFixed(0)} px',
                          onChanged: (v) => liveUpdate(() => _separationForce = v),
                        ),
                        _slider(
                          label: 'Spring Strength',
                          value: _separationSpring,
                          min: 0.05, max: 0.95,
                          hint: 'Low = gradual arc · High = sharp snap',
                          onChanged: (v) => liveUpdate(() => _separationSpring = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Slider widget ─────────────────────────────────────────────────────────
  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
    String? display,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              Text(
                display ?? value.toStringAsFixed(2),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C63FF)),
              ),
            ],
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(hint,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF6C63FF),
              thumbColor: const Color(0xFF6C63FF),
              inactiveTrackColor:
              const Color(0xFF6C63FF).withOpacity(0.2),
              overlayColor: const Color(0xFF6C63FF).withOpacity(0.1),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(title,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.6)),
  );

  Widget _buildCard(int index) => Container(
    width: imageSize,
    height: imageSize,
    decoration: BoxDecoration(
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
      ],
    ),
    child: Center(
      child: Text(_labels[index],
          style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold)),
    ),
  );
}

// import 'dart:math' as math;
//
// import 'package:flutter/material.dart';
//
// import '../widget/physics_controllers.dart';
//
// class ShopPillowAnimationPage extends StatefulWidget {
//   const ShopPillowAnimationPage({super.key});
//
//   @override
//   State<ShopPillowAnimationPage> createState() => _ShopPillowAnimationPageState();
// }
//
// class _ShopPillowAnimationPageState extends State<ShopPillowAnimationPage> with TickerProviderStateMixin {
//   late List<AnimationController> _controllers;
//   late List<Animation<double>> _paths;
//
//   late AnimationController _spacingController;
//   late Animation<double> _spacingAnimation;
//
//   final MotionProfile _profile = MotionProfile(
//     mass: 0.6,
//     stiffness: 170.0,
//     damping: 25.0,
//   );
//
//   double _angleMultiplier = 0.5;
//   double _finalCurveDepth = 10.0;
//   double _dropDistanceFactor = 0.18;
//
//   static const double imageSize = 85.0;
//
//   final List<String> _labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//   }
//
//   void _initAnimations() {
//     _controllers = List.generate(
//       _labels.length,
//           (index) => AnimationController(
//         vsync: this,
//         duration: _profile.dynamicDuration,
//       ),
//     );
//
//     _paths = _controllers.map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: c,
//         curve: Curves.easeInOutSine,
//       ),
//     )).toList();
//
//     _spacingController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//
//     _spacingAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
//       CurvedAnimation(parent: _spacingController, curve: Curves.easeOutBack),
//     );
//   }
//
//   void _reinitAnimations() {
//     for (final c in _controllers) {
//       c.dispose();
//     }
//     _spacingController.dispose();
//     _initAnimations();
//     setState(() {});
//   }
//
//   Future<void> _toggleAnimation() async {
//     final int sequenceDelay = (_profile.dynamicDuration.inMilliseconds * 0.25).toInt();
//
//     for (int i = 0; i < _controllers.length; i++) {
//       _controllers[i].forward();
//       await Future.delayed(Duration(milliseconds: sequenceDelay));
//     }
//
//     await Future.delayed(_profile.dynamicDuration);
//     await _spacingController.forward();
//   }
//
//   void _resetAnimation() {
//     for (final c in _controllers) {
//       c.reset();
//     }
//     _spacingController.reset();
//     setState(() {});
//   }
//
//   @override
//   void dispose() {
//     for (final c in _controllers) {
//       c.dispose();
//     }
//     _spacingController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double dropDistance = screenHeight * _dropDistanceFactor;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 80),
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.only(left: 40),
//                 child: AnimatedBuilder(
//                   animation: Listenable.merge([..._controllers, _spacingController]),
//                   builder: (context, _) {
//                     return Stack(
//                       clipBehavior: Clip.none,
//                       children: List.generate(_labels.length, (i) {
//                         final double t = _paths[i].value;
//                         final double spacing = _spacingAnimation.value;
//
//                         double stepSize = imageSize + spacing;
//
//                         double xShiftFactor = 0;
//                         for (int j = i; j < _labels.length; j++) {
//                           xShiftFactor += _paths[j].value;
//                         }
//
//                         double baseTargetX = (xShiftFactor * stepSize) - stepSize;
//                         if (baseTargetX < 0) baseTargetX = 0;
//
//                         double currentY = 0;
//                         double angleX = 0;
//                         double endCurveX = 0;
//
//                         if (t > 0.4) {
//                           double tDrop = (t - 0.4) / 0.6;
//                           currentY = tDrop * dropDistance;
//                           angleX = currentY * _angleMultiplier;
//
//                           if (tDrop > 0.8) {
//                             double tEnd = (tDrop - 0.8) / 0.2;
//                             endCurveX = math.sin(tEnd * math.pi) * _finalCurveDepth;
//                           }
//                         }
//
//                         return Positioned(
//                           left: baseTargetX - angleX - endCurveX,
//                           top: currentY,
//                           child: _buildCard(i),
//                         );
//                       }),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 30),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _toggleAnimation,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF6C63FF),
//                       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     ),
//                     child: const Text('Animate', style: TextStyle(color: Colors.white, fontSize: 18)),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton(
//                     onPressed: _showControlsSheet,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF0EEFF),
//                       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                       elevation: 0,
//                     ),
//                     child: const Icon(Icons.tune_rounded, color: Color(0xFF6C63FF)),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showControlsSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.6,
//           minChildSize: 0.3,
//           maxChildSize: 1.0,
//           snap: true,
//           snapSizes: const [0.3, 0.6, 1.0],
//           builder: (context, scrollController) {
//             return StatefulBuilder(
//               builder: (context, setSheetState) {
//                 return Container(
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFFAFAFF),
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//                     boxShadow: [
//                       BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4)),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       // Drag handle
//                       Padding(
//                         padding: const EdgeInsets.only(top: 12, bottom: 8),
//                         child: Container(
//                           width: 40,
//                           height: 4,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                       ),
//                       // Header
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.tune_rounded, color: Color(0xFF6C63FF), size: 20),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'Physics Controls',
//                               style: TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFF6C63FF),
//                               ),
//                             ),
//                             const Spacer(),
//                             OutlinedButton.icon(
//                               onPressed: () {
//                                 _resetAnimation();
//                                 setSheetState(() {});
//                               },
//                               icon: const Icon(Icons.replay, size: 15),
//                               label: const Text('Reset'),
//                               style: OutlinedButton.styleFrom(
//                                 foregroundColor: const Color(0xFF6C63FF),
//                                 side: const BorderSide(color: Color(0xFF6C63FF)),
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                 textStyle: const TextStyle(fontSize: 13),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Divider(height: 1),
//                       // Scrollable sliders
//                       Expanded(
//                         child: ListView(
//                           controller: scrollController,
//                           padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
//                           children: [
//                             _sectionLabel('Spring Physics'),
//                             _sheetSlider(
//                               label: 'Mass',
//                               value: _profile.mass,
//                               min: 0.5,
//                               max: 3.0,
//                               onChanged: (v) {
//                                 setSheetState(() => _profile.mass = v);
//                                 _reinitAnimations();
//                               },
//                             ),
//                             _sheetSlider(
//                               label: 'Stiffness',
//                               value: _profile.stiffness,
//                               min: 50,
//                               max: 600,
//                               onChanged: (v) {
//                                 setSheetState(() => _profile.stiffness = v);
//                                 _reinitAnimations();
//                               },
//                             ),
//                             _sheetSlider(
//                               label: 'Damping',
//                               value: _profile.damping,
//                               min: 1,
//                               max: 40,
//                               onChanged: (v) {
//                                 setSheetState(() => _profile.damping = v);
//                                 _reinitAnimations();
//                               },
//                             ),
//                             _sheetSlider(
//                               label: 'Drag',
//                               value: _profile.drag,
//                               min: 0.02,
//                               max: 0.5,
//                               onChanged: (v) {
//                                 setSheetState(() => _profile.drag = v);
//                                 _reinitAnimations();
//                               },
//                             ),
//                             const SizedBox(height: 12),
//                             _sectionLabel('Motion Parameters'),
//                             _sheetSlider(
//                               label: 'Angle Multiplier',
//                               value: _angleMultiplier,
//                               min: 0.1,
//                               max: 1.0,
//                               onChanged: (v) => setSheetState(() {
//                                 _angleMultiplier = v;
//                                 setState(() {});
//                               }),
//                             ),
//                             _sheetSlider(
//                               label: 'Final Curve Depth',
//                               value: _finalCurveDepth,
//                               min: 0,
//                               max: 200,
//                               onChanged: (v) => setSheetState(() {
//                                 _finalCurveDepth = v;
//                                 setState(() {});
//                               }),
//                             ),
//                             _sheetSlider(
//                               label: 'Drop Distance',
//                               value: _dropDistanceFactor,
//                               min: 0.12,
//                               max: 0.50,
//                               displayValue: '${(_dropDistanceFactor * 100).toStringAsFixed(0)}% of screen',
//                               onChanged: (v) => setSheetState(() {
//                                 _dropDistanceFactor = v;
//                                 setState(() {});
//                               }),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _sectionLabel(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8, top: 4),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: Colors.grey,
//           letterSpacing: 0.5,
//         ),
//       ),
//     );
//   }
//
//   Widget _sheetSlider({
//     required String label,
//     required double value,
//     required double min,
//     required double max,
//     required ValueChanged<double> onChanged,
//     String? displayValue,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//               Text(
//                 displayValue ?? value.toStringAsFixed(2),
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF6C63FF),
//                 ),
//               ),
//             ],
//           ),
//           SliderTheme(
//             data: SliderThemeData(
//               activeTrackColor: const Color(0xFF6C63FF),
//               thumbColor: const Color(0xFF6C63FF),
//               inactiveTrackColor: const Color(0xFF6C63FF).withOpacity(0.2),
//               overlayColor: const Color(0xFF6C63FF).withOpacity(0.1),
//               trackHeight: 3,
//             ),
//             child: Slider(value: value, min: min, max: max, onChanged: onChanged),
//           ),
//           Divider(height: 1, color: Colors.grey.shade200),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCard(int index) {
//     return Container(
//       width: imageSize,
//       height: imageSize,
//       decoration: BoxDecoration(
//         color: Colors.blueAccent,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//         ],
//       ),
//       child: Center(
//         child: Text(
//           _labels[index],
//           style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }