import 'dart:math' as math;
import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/material.dart';

// Smooth profile smoothing curve
double _smootherstep(double t) {
  t = t.clamp(0.0, 1.0);
  return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

// ─── Controls data bag ─────────────────────────────────────────────────────
class _ControlsData {
  double mass, stiffness, damping, drag;
  double separationForce, separationSpring;
  double dropDistanceFactor, dropDistance;

  _ControlsData({
    required this.mass,
    required this.stiffness,
    required this.damping,
    required this.drag,
    required this.separationForce,
    required this.separationSpring,
    required this.dropDistanceFactor,
    required this.dropDistance,
  });
}

// ─── Bottom sheet ──────────────────────────────────────────────────────────
class _ControlsSheet extends StatefulWidget {
  final double mass, stiffness, damping, drag;
  final double separationForce, separationSpring;
  final double dropDistanceFactor, dropDistance;
  final void Function(_ControlsData) onChanged;

  const _ControlsSheet({
    required this.mass,
    required this.stiffness,
    required this.damping,
    required this.drag,
    required this.separationForce,
    required this.separationSpring,
    required this.dropDistanceFactor,
    required this.dropDistance,
    required this.onChanged,
  });

  @override
  State<_ControlsSheet> createState() => _ControlsSheetState();
}

class _ControlsSheetState extends State<_ControlsSheet> {
  late _ControlsData _data;

  @override
  void initState() {
    super.initState();
    _data = _ControlsData(
      mass: widget.mass,
      stiffness: widget.stiffness,
      damping: widget.damping,
      drag: widget.drag,
      separationForce: widget.separationForce,
      separationSpring: widget.separationSpring,
      dropDistanceFactor: widget.dropDistanceFactor,
      dropDistance: widget.dropDistance,
    );
  }

  void _emit() => widget.onChanged(_data);

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int divisions = 100,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(value.toStringAsFixed(2), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6C63FF),
              thumbColor: const Color(0xFF6C63FF),
              overlayColor: const Color(0x296C63FF),
              inactiveTrackColor: const Color(0xFFD9D7F1),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (v) {
                setState(() => onChanged(v));
                _emit();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6C63FF), letterSpacing: 1.1)),
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.60,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 2)],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Animation Controls', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: sc,
                children: [
                  _sectionTitle('MOTION PROFILE'),
                  _slider(label: 'Mass', value: _data.mass, min: 0.1, max: 5.0, onChanged: (v) => _data.mass = v),
                  _slider(label: 'Stiffness', value: _data.stiffness, min: 10.0, max: 300.0, onChanged: (v) => _data.stiffness = v),
                  _slider(label: 'Damping', value: _data.damping, min: 1.0, max: 80.0, onChanged: (v) => _data.damping = v),
                  _slider(label: 'Drag', value: _data.drag, min: 0.0, max: 1.0, onChanged: (v) => _data.drag = v),
                  _sectionTitle('DROP'),
                  _slider(label: 'Drop Distance', value: _data.dropDistance, min: 0.0, max: 400.0, onChanged: (v) => _data.dropDistance = v),
                  _slider(label: 'Drop Distance Factor', value: _data.dropDistanceFactor, min: 0.0, max: 1.0, divisions: 100, onChanged: (v) => _data.dropDistanceFactor = v),
                  _sectionTitle('SEPARATION'),
                  _slider(label: 'Separation Force', value: _data.separationForce, min: 0.0, max: 120.0, onChanged: (v) => _data.separationForce = v),
                  _slider(label: 'Separation Spring', value: _data.separationSpring, min: 0.0, max: 1.0, onChanged: (v) => _data.separationSpring = v),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Main widget ───────────────────────────────────────────────────────────
class ShopPillowCircleRound extends StatefulWidget {
  const ShopPillowCircleRound({super.key});

  @override
  State<ShopPillowCircleRound> createState() => _ShopPillowCircleRoundState();
}

class _ShopPillowCircleRoundState extends State<ShopPillowCircleRound> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late MotionProfile _profile;

  double _separationForce    = 45.0;
  double _separationSpring   = 0.50;
  double _dropDistanceFactor = 0.35;
  double _dropDistance       = 60.0;

  static const double imageSize = 85.0;

  // Track scroll interaction values directly tied to the Stack position rules
  double _scrollOffset = 0.0;
  bool _isAnimationComplete = false;

  // Geometric layout parameters
  static const double _nEntryX  = -0.2230;
  static const double _nEntryY  =  0.9749;
  static const double _nCentreX = -0.4447;
  static const double _nCentreY =  0.9459;
  static const double _nRadius  =  0.2141;

  static const double _angEntry = 7.4  * math.pi / 180.0;
  static const double _sweepCW  = 256.9 * math.pi / 180.0;

  final List<String> _labels = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'
  ];

  @override
  void initState() {
    super.initState();
    _profile = MotionProfile(mass: 1.70, stiffness: 110.0, damping: 24.0, drag: 0.05);
    _buildControllers();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  void _buildControllers() {
    _controllers = List.generate(
      _labels.length,
          (_) => AnimationController(vsync: this, duration: _profile.dynamicDuration),
    );
  }

  void _reinitControllers() {
    for (final c in _controllers) c.dispose();
    _buildControllers();
    setState(() {});
  }

  Future<void> _playAnimation() async {
    _resetAnimation();

    // Spacing stagger time between items
    final int staggerDelay = (_profile.dynamicDuration.inMilliseconds * 0.050).toInt();

    // Explicitly listen to the final tail controller to toggle scroll mechanics immediately
    _controllers.last.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimationComplete = true;
        });
      }
    });

    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].forward();
      await Future.delayed(Duration(milliseconds: staggerDelay));
    }
  }

  void _resetAnimation() {
    for (final c in _controllers) c.reset();
    setState(() {
      _scrollOffset = 0.0;
      _isAnimationComplete = false;
    });
  }

// ─── Cubic Bézier (1-D) matching your physics file exactly ──────────────────
  double _cubicBez(double t, double p1, double p2) {
    final u = 1 - t;
    return 3 * u * u * t * p1 + 3 * u * t * t * p2;
  }

  // ─── Continuous Uninterrupted Path Calculation ──────────────────────────
  ({double x, double y, double opacity}) _cardState(int i, double diagLen, double screenW) {
    final double pathT = _controllers[i].value;

    // Geometry parameters
    final double r       = _nRadius  * diagLen;
    final double centreX = _nCentreX * diagLen;
    final double centreY = _nCentreY * diagLen;

    final double path1EndX = _nEntryX * diagLen;
    final double path1EndY = _nEntryY * diagLen;

    final double exitTheta = _angEntry + _sweepCW;
    final double exitX = centreX + r * math.cos(exitTheta);
    final double exitY = centreY + r * math.sin(exitTheta);

    // Fixed track segment calibration
    final double dist1 = math.sqrt(path1EndX * path1EndX + path1EndY * path1EndY);
    final double dist2 = r * _sweepCW;
    final double loopDist = dist1 + dist2;

    // Track spacing boundaries
    const double cardSize = imageSize;
    const double finalSpacing = 10.0;
    final int reverseIndex = _controllers.length - 1 - i;

    final double packedRestPosition = reverseIndex * cardSize;
    final double expandedRestPosition = reverseIndex * (cardSize + finalSpacing);

    // Calculate maximum distance matching the absolute length of the train track line
    final double maxDist3 = (_controllers.length - 1) * (cardSize + finalSpacing);
    final double absoluteMaxDistance = loopDist + maxDist3;

    // Individual distance traveled along track
    final double currentDist = pathT * absoluteMaxDistance;

    double currentX = 0.0;
    double currentY = 0.0;

    // ── 1. CORE MOTION LAYOUT TRACK ──
    if (currentDist <= dist1) {
      final double t = currentDist / dist1;
      currentX = path1EndX * t;
      currentY = path1EndY * t;
    } else if (currentDist <= loopDist) {
      final double t = (currentDist - dist1) / dist2;
      final double theta = _angEntry + (t * _sweepCW);
      currentX = centreX + r * math.cos(theta);
      currentY = centreY + r * math.sin(theta);
    } else {
      final double distanceOnExitLine = currentDist - loopDist;

      if (distanceOnExitLine >= packedRestPosition) {
        currentX = exitX + packedRestPosition;
        currentY = exitY;
      } else {
        currentX = exitX + distanceOnExitLine;
        currentY = exitY;
      }
    }

    // ── 2. INSTANT GEOMETRIC SPRING POP TRIGGER ──
    // Track the physical location of the trailing card (the last controller in the stack)
    final double lastCardDist = _controllers.last.value * absoluteMaxDistance;

    // The instant the trailing card crosses the loop exit point, start the pop!
    if (lastCardDist > loopDist) {
      // Calculate a local progress timeline based purely on the last card's remaining journey
      final double totalRemainingTrack = absoluteMaxDistance - loopDist;
      final double currentProgressTrack = lastCardDist - loopDist;

      final double tGlobalFinish = totalRemainingTrack > 0
          ? (currentProgressTrack / totalRemainingTrack).clamp(0.0, 1.0)
          : 1.0;

      // Extract structural physics handles
      final double p1 = _separationSpring * 0.9 + 0.05;
      final double p2 = (1.0 - _separationSpring) * 0.9 + 0.05;

      // Compute the exact bounce displacement pulse
      final double springFactor = _cubicBez(tGlobalFinish, p1, p2);
      final double sepX = springFactor * _separationForce;

      // Smoothly expand the structural spacing gaps concurrently with the arrival deceleration
      final double dynamicSpacingOffset = (expandedRestPosition - packedRestPosition) * tGlobalFinish;

      currentX += dynamicSpacingOffset - sepX;
    }

    return (x: currentX, y: currentY, opacity: 1.0);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.of(context).size.height;
    final double screenW = MediaQuery.of(context).size.width;

    final double diagLen = screenH * _dropDistanceFactor + _dropDistance;
    final double startLeft = screenW * 0.55;
    const double startTop  = 30.0;

    // Calculate exactly where the track ends and how wide the items are
    final double r = _nRadius * diagLen;
    final double centreX = _nCentreX * diagLen;
    final double exitTheta = _angEntry + _sweepCW;
    final double exitX = centreX + r * math.cos(exitTheta);

    const double finalSpacing = 10.0;
    final double totalCardsWidth = (_labels.length * imageSize) + ((_labels.length - 1) * finalSpacing);

    // Total physical width of the scroll workspace
    final double totalContentWidth = startLeft + exitX + totalCardsWidth + 40.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // Automatically unlocks BouncingScrollPhysics on iOS & AlwaysScrollable everywhere
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: AnimatedBuilder(
                  animation: Listenable.merge(_controllers),
                  builder: (context, _) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Invisible spacer that creates native scrollable bounds matching your math
                      SizedBox(
                        width: totalContentWidth,
                        height: screenH,
                      ),

                      // Your original structural mapping loop remains completely untouched
                      ...List.generate(_labels.length, (i) {
                        final state = _cardState(i, diagLen, screenW);
                        return Positioned(
                          left: startLeft + state.x,
                          top:  startTop  + state.y,
                          child: Opacity(
                            opacity: state.opacity,
                            child: _buildCard(i),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _playAnimation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Animate', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _showControlsSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0EEFF),
              padding: const EdgeInsets.all(18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Icon(Icons.tune_rounded, color: Color(0xFF6C63FF)),
          ),
        ],
      ),
    );
  }

  void _showControlsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ControlsSheet(
        mass: _profile.mass,
        stiffness: _profile.stiffness,
        damping: _profile.damping,
        drag: _profile.drag,
        separationForce: _separationForce,
        separationSpring: _separationSpring,
        dropDistanceFactor: _dropDistanceFactor,
        dropDistance: _dropDistance,
        onChanged: (d) {
          setState(() {
            _profile
              ..mass      = d.mass
              ..stiffness = d.stiffness
              ..damping   = d.damping
              ..drag      = d.drag;
            _separationForce    = d.separationForce;
            _separationSpring   = d.separationSpring;
            _dropDistanceFactor = d.dropDistanceFactor;
            _dropDistance       = d.dropDistance;
          });
          _reinitControllers();
        },
      ),
    );
  }

  Widget _buildCard(int index) => Container(
    width: imageSize,
    height: imageSize,
    decoration: BoxDecoration(
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
    ),
    child: Center(
      child: Text(
        _labels[index],
        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      ),
    ),
  );
}