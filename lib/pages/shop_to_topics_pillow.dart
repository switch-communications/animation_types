import 'dart:math' as math;
import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/material.dart';

double _smootherstep(double t) {
  t = t.clamp(0.0, 1.0);
  return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

double _easeOutBack(double t, {double overshoot = 0.18}) {
  t = t.clamp(0.0, 1.0);
  final double c1 = overshoot;
  final double c3 = c1 + 1.0;
  return 1.0 + c3 * math.pow(t - 1.0, 3) + c1 * math.pow(t - 1.0, 2);
}

class _ControlsData {
  double mass, stiffness, damping, drag;
  double separationForce, separationSpring;
  double dropDistanceFactor, dropDistance;
  double overshootPx;
  double targetSpacing;

  _ControlsData({
    required this.mass,
    required this.stiffness,
    required this.damping,
    required this.drag,
    required this.separationForce,
    required this.separationSpring,
    required this.dropDistanceFactor,
    required this.dropDistance,
    required this.overshootPx,
    required this.targetSpacing,
  });
}

class _ControlsSheet extends StatefulWidget {
  final double mass, stiffness, damping, drag;
  final double separationForce, separationSpring;
  final double dropDistanceFactor, dropDistance;
  final double overshootPx;
  final double targetSpacing;
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
    required this.overshootPx,
    required this.targetSpacing,
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
      overshootPx: widget.overshootPx,
      targetSpacing: widget.targetSpacing,
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
                  _sectionTitle('PULL BACK'),
                  _slider(label: 'Target Spacing', value: _data.targetSpacing, min: 0.0, max: 80.0, onChanged: (v) => _data.targetSpacing = v),
                  _slider(label: 'Overshoot', value: _data.overshootPx, min: 0.0, max: 60.0, onChanged: (v) => _data.overshootPx = v),
                  _sectionTitle('DROP'),
                  _slider(label: 'Drop Distance', value: _data.dropDistance, min: 0.0, max: 400.0, onChanged: (v) => _data.dropDistance = v),
                  _slider(label: 'Drop Distance Factor', value: _data.dropDistanceFactor, min: 0.0, max: 1.0, divisions: 100, onChanged: (v) => _data.dropDistanceFactor = v),
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

class ShopToTopicsPillow extends StatefulWidget {
  const ShopToTopicsPillow({super.key});

  @override
  State<ShopToTopicsPillow> createState() => _ShopToTopicsPillowState();
}

class _ShopToTopicsPillowState extends State<ShopToTopicsPillow>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late MotionProfile _profile;

  double _separationForce    = 45.0;
  double _separationSpring   = 0.50;
  double _dropDistanceFactor = 0.35;
  double _dropDistance       = 60.0;
  double _overshootPx        = 1.0;
  double _targetSpacing      = 10.0;

  static const double imageSize     = 80.0;
  static const double exitImageSize = 200.0;

  // _pathPhase: fraction of master controller used for the path animation.
  // After _pathPhase the controller continues to drive the exit fan-out.
  // We extend it to 1.0 so the full controller range is used end-to-end.
  static const double _pathPhase      = 0.65;
  static const double _spacingOverlap = 0.15;
  static const double _peakAt         = 0.68;

  bool _isAnimationComplete = false;

  static const double _nEntryX  = -0.2230;
  static const double _nEntryY  =  0.9749;
  static const double _nCentreX = -0.4447;
  static const double _nCentreY =  0.9459;
  static const double _nRadius  =  0.2141;
  static const double _angEntry =  7.4   * math.pi / 180.0;
  static const double _sweepCW  =  256.9 * math.pi / 180.0;

  final List<String> _labels = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
  ];


  @override
  void initState() {
    super.initState();
    _profile = MotionProfile(mass: 1.70, stiffness: 110.0, damping: 24.0, drag: 0.05);
    _buildController();
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  void _buildController() {
    final int pathMs    = (_profile.dynamicDuration.inMilliseconds * 1.8).toInt();
    const int spacingMs = 800;
    final int totalMs   = math.max(
      (pathMs / _pathPhase).toInt(),
      pathMs + spacingMs,
    );
    _masterController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );
  }

  void _reinitController() {
    _masterController.dispose();
    _buildController();
    setState(() {});
  }

  double get _pathProgress =>
      (_masterController.value / _pathPhase).clamp(0.0, 1.0);

  double get _spacingProgress {
    final double start = _pathPhase - _spacingOverlap;
    return ((_masterController.value - start) / (1.0 - start)).clamp(0.0, 1.0);
  }

  Future<void> _playAnimation() async {
    _resetAnimation();
    _logFrameCount = 0; // ← add this
    _masterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isAnimationComplete = true);
      }
    });
    _masterController.forward();
  }

  void _resetAnimation() {
    _masterController.reset();
    setState(() => _isAnimationComplete = false);
  }

  Offset _getPointOnPath(double d, double diagLen) {
    final double r         = _nRadius  * diagLen;
    final double centreX   = _nCentreX * diagLen;
    final double centreY   = _nCentreY * diagLen;
    final double path1EndX = _nEntryX  * diagLen;
    final double path1EndY = _nEntryY  * diagLen;
    final double dist1     = math.sqrt(path1EndX * path1EndX + path1EndY * path1EndY);

    if (d <= dist1) {
      if (dist1 == 0) return Offset.zero;
      final double t = d / dist1;
      return Offset(path1EndX * t, path1EndY * t);
    } else {
      final double t     = (d - dist1) / (r * _sweepCW);
      final double theta = _angEntry + (t * _sweepCW);
      return Offset(centreX + r * math.cos(theta), centreY + r * math.sin(theta));
    }
  }

  ({double x, double y, double opacity, double size}) _cardState(int i, double diagLen, double screenW) {
    final double r         = _nRadius  * diagLen;
    final double centreX   = _nCentreX * diagLen;
    final double centreY   = _nCentreY * diagLen;
    final double path1EndX = _nEntryX  * diagLen;
    final double path1EndY = _nEntryY  * diagLen;
    final double exitTheta = _angEntry + _sweepCW;
    final double exitX     = centreX + r * math.cos(exitTheta);
    final double exitY     = centreY + r * math.sin(exitTheta);
    final double dist1     = math.sqrt(path1EndX * path1EndX + path1EndY * path1EndY);
    final double dist2     = r * _sweepCW;
    final double loopDist  = dist1 + dist2;
    final double maxDist3            = (_labels.length - 1) * imageSize;
    final double absoluteMaxDistance = loopDist + maxDist3 + imageSize;

    final double masterDistance = _pathProgress * absoluteMaxDistance;
    double currentDist = masterDistance - (i * imageSize);

    double currentX = 0.0;
    double currentY = 0.0;
    bool   onExitLine = false;

    if (currentDist < loopDist) {
      if (currentDist <= dist1 && i > 0) {
        const double uniformDropBuffer = 4.0;
        final double closingFactor = (1.0 - (currentDist / dist1)).clamp(0.0, 1.0);
        currentDist -= (uniformDropBuffer * closingFactor);
        if (currentDist < 0) currentDist = 0;
      }
      final Offset point = _getPointOnPath(currentDist, diagLen);
      currentX = point.dx;
      currentY = point.dy;
    } else {
      onExitLine = true;
    }

    // ── Spacing drift ──────────────────────────────────────────────────────
    final int reverseIndex        = _labels.length - 1 - i;
    final double cardStaggerStart = i * 0.01;
    final double dynamicNormalizedProgress =
    ((_spacingProgress - cardStaggerStart) / (1.0 - cardStaggerStart)).clamp(0.0, 1.0);

    double spacingAtThisFrame;
    if (dynamicNormalizedProgress <= _peakAt) {
      final double t = _smootherstep(dynamicNormalizedProgress / _peakAt);
      spacingAtThisFrame = (_targetSpacing + _overshootPx) * t;
    } else {
      final double t = _smootherstep((dynamicNormalizedProgress - _peakAt) / (1.0 - _peakAt));
      spacingAtThisFrame = (_targetSpacing + _overshootPx) - (_overshootPx * t);
    }

    if (!onExitLine) {
      final double totalDrift = reverseIndex * spacingAtThisFrame;
      currentX += totalDrift;

      double cardSize = imageSize;
      if (currentDist > dist1) {
        final double arcProgress = ((currentDist - dist1) / dist2).clamp(0.0, 1.0);
        final double rawT = arcProgress * 0.90;
        cardSize = imageSize + (exitImageSize - imageSize) * rawT;
      }

      return (x: currentX, y: currentY, opacity: 1.0, size: cardSize);
    }

// ── Sequential exit ────────────────────────────────────────────────────
    final double cardExitCtrl = ((loopDist + i * imageSize) / absoluteMaxDistance) * _pathPhase;

    final double remainingWindow = 1.0 - cardExitCtrl;
    final double fanT = remainingWindow > 0
        ? ((_masterController.value - cardExitCtrl) / remainingWindow).clamp(0.0, 1.0)
        : 1.0;

    final double rawT     = 0.90 + 0.10 * fanT;
    final double cardSize = imageSize + (exitImageSize - imageSize) * rawT;

// Use fixed exitImageSize for slot calculation so positions don't shift as cards grow
    final double finalSlotX = exitX + (_labels.length - 1 - i) * exitImageSize;
    currentX = exitX + (finalSlotX - exitX) * _easeOutBack(fanT, overshoot: 0.10);
    currentY = exitY;

    // ── LOG every card every frame on exit line ──────────────────────────
    debugPrint(
      '[EXIT] ctrl=${(_masterController.value * 100).toStringAsFixed(1)}%'
          '  card=$i  rev=$reverseIndex'
          '  cardExitCtrl=${(cardExitCtrl * 100).toStringAsFixed(1)}%'
          '  fanT=${fanT.toStringAsFixed(3)}'
          '  cardSize=${cardSize.toStringAsFixed(1)}'
          '  exitX=${exitX.toStringAsFixed(1)}'
          '  finalSlotX=${finalSlotX.toStringAsFixed(1)}'
          '  currentX=${currentX.toStringAsFixed(1)}'
          '  rightEdge=${(currentX + cardSize).toStringAsFixed(1)}'
          '  gap_to_prev=${i > 0 ? "check_next_card" : "LEAD"}',
    );

    return (x: currentX, y: currentY, opacity: 1.0, size: cardSize);
  }

  int _logFrameCount = 0;

  void _logCardGaps(double diagLen, double screenW) {
    _logFrameCount++;
    if (_logFrameCount % 10 != 0) return;

    final results = List.generate(_labels.length, (i) => _cardState(i, diagLen, screenW));

    final double r       = _nRadius * diagLen;
    final double centreX = _nCentreX * diagLen;
    final double exitX   = centreX + r * math.cos(_angEntry + _sweepCW);

    final anyOnExit = results.any((r) => r.x >= exitX - 5);
    if (!anyOnExit) return;

    debugPrint('═══ GAPS @ ctrl=${(_masterController.value * 100).toStringAsFixed(1)}% ═══');
    for (int i = 0; i < results.length - 1; i++) {
      final curr = results[i];
      final next = results[i + 1];
      final gap = curr.x - (next.x + next.size);
      debugPrint(
        '  card[$i]←→card[${i+1}]'
            '  [$i].x=${curr.x.toStringAsFixed(1)}'
            '  [${i+1}].right=${(next.x + next.size).toStringAsFixed(1)}'
            '  GAP=${gap.toStringAsFixed(1)}px'
            '  ${gap.abs() < 2 ? "✓" : gap > 2 ? "⚠GAP" : "⚠OVERLAP"}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.of(context).size.height;
    final double screenW = MediaQuery.of(context).size.width;
    final double diagLen = screenH * _dropDistanceFactor + _dropDistance;
    final double startLeft = screenW * 0.55;
    const double startTop  = 30.0;

    final double r             = _nRadius * diagLen;
    final double centreX       = _nCentreX * diagLen;
    final double exitTheta     = _angEntry + _sweepCW;
    final double exitX         = centreX + r * math.cos(exitTheta);
    final double totalCardsWidth   = _labels.length * (exitImageSize + _targetSpacing);
    final double totalContentWidth = startLeft + exitX + totalCardsWidth + 120.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: AnimatedBuilder(
                    animation: _masterController,
                    builder: (context, _) {
                      _logCardGaps(diagLen, screenW);
                      return
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(width: totalContentWidth, height: screenH),
                            ...List.generate(_labels.length, (i) => _labels.length - 1 - i).map((i) {
                              final state = _cardState(i, diagLen, screenW);
                              return Positioned(
                                left: startLeft + state.x,
                                top: startTop + state.y,
                                child: Opacity(
                                  opacity: state.opacity,
                                  child: _buildCard(i, size: state.size),
                                ),
                              );
                            }),
                          ],
                        );
                    }
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
        overshootPx: _overshootPx,
        targetSpacing: _targetSpacing,
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
            _overshootPx        = d.overshootPx;
            _targetSpacing      = d.targetSpacing;
          });
          _reinitController();
        },
      ),
    );
  }

  Widget _buildCard(int index, {double size = imageSize}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        "assets/images/sample${index % 2 == 0 ? '2' : ''}.jpg",
        fit: BoxFit.cover,
      ),
    ),
  );
}