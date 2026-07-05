import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

// =====================================================================
// Path geometry — STORIES_WATERFALL_PATH.svg (viewBox 264 x 539)
// =====================================================================
class _WaterfallPath {
  static Path build(Size size) {
    const srcW = 264.0;
    const srcH = 539.0;
    final sx = size.width / srcW;
    final sy = size.height / srcH;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final start = p(217.5, 1.78516);
    final c1a   = p(217.5, 1.78516);
    final c1b   = p(288.5, 71.2812);
    final e1    = p(249,   149.276);
    final c2a   = p(209.5, 227.271);
    final c2b   = p(2.49973, 275.783);
    final e2    = p(2.5,   400.283);
    final c3a   = p(2.50027, 524.784);
    final c3b   = p(95.5,  535.783);
    final e3    = p(95.5,  535.783);

    final raw = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1a.dx, c1a.dy, c1b.dx, c1b.dy, e1.dx, e1.dy)
      ..cubicTo(c2a.dx, c2a.dy, c2b.dx, c2b.dy, e2.dx, e2.dy)
      ..cubicTo(c3a.dx, c3a.dy, c3b.dx, c3b.dy, e3.dx, e3.dy);

    final dx = size.width / 2 - start.dx;
    return raw.shift(Offset(dx, 0));
  }

  /// Arc-length from path start to mid of curve 2 — trigger point.
  static double triggerArcLength(Size size) {
    const srcW = 264.0;
    const srcH = 539.0;
    final sx = size.width / srcW;
    final sy = size.height / srcH;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final start = p(217.5, 1.78516);
    final c1a   = p(217.5, 1.78516);
    final c1b   = p(288.5, 71.2812);
    final e1    = p(249,   149.276);
    final c2a   = p(209.5, 227.271);
    final c2b   = p(2.49973, 275.783);
    final e2    = p(2.5,   400.283);

    final seg1 = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1a.dx, c1a.dy, c1b.dx, c1b.dy, e1.dx, e1.dy);

    final seg1and2 = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1a.dx, c1a.dy, c1b.dx, c1b.dy, e1.dx, e1.dy)
      ..cubicTo(c2a.dx, c2a.dy, c2b.dx, c2b.dy, e2.dx, e2.dy);

    final s1  = seg1.computeMetrics().first.length;
    final s12 = seg1and2.computeMetrics().first.length;
    return s1 + (s12 - s1) / 2;
  }
}

// =====================================================================
// Arc-length lookup table
// =====================================================================
class _ArcLengthTable {
  _ArcLengthTable(Path path, {this.samples = 300}) {
    final metric  = path.computeMetrics().first;
    totalLength   = metric.length;
    final safeLen = totalLength - 0.01;
    _points = List<Offset>.generate(samples + 1, (i) {
      final d = (safeLen * i / samples).clamp(0, safeLen);
      return metric.getTangentForOffset(d.toDouble())!.position;
    });
  }

  final int      samples;
  double         totalLength = 0;
  List<Offset>   _points     = [];

  Offset positionAt(double distance) {
    final f = (distance.clamp(0, totalLength) / totalLength * samples);
    final i = f.floor().clamp(0, samples - 1);
    return Offset.lerp(_points[i], _points[i + 1], f - i)!;
  }

  Offset get endPosition => _points.isEmpty ? Offset.zero : _points[samples];
}

double _smootherstep(double t) {
  final x = t.clamp(0.0, 1.0);
  return x * x * x * (x * (x * 6 - 15) + 10);
}

// =====================================================================
// Per-card state  — NO late fields
// =====================================================================
class _CardState {
  _CardState({
    required this.pathCtrl,
    required this.expandCtrl,
    required this.slideCtrl,
  });

  final AnimationController pathCtrl;
  final AnimationController expandCtrl;
  final AnimationController slideCtrl;

  bool   travelDone        = false;
  bool   nextTriggered     = false;
  bool   expandComplete    = false;
  double slideBaseOffset   = 0.0;
  double slideTargetOffset = 0.0;
  Offset lastTravelPos     = Offset.zero; // exact pixel pos when travel ended

  void dispose() {
    pathCtrl.dispose();
    expandCtrl.dispose();
    slideCtrl.dispose();
  }

  void reset() {
    pathCtrl.reset();
    expandCtrl.reset();
    slideCtrl.reset();
    travelDone        = false;
    nextTriggered     = false;
    expandComplete    = false;
    slideBaseOffset   = 0.0;
    slideTargetOffset = 0.0;
    lastTravelPos     = Offset.zero;
  }
}

// =====================================================================
// Widget
// =====================================================================
class TopicsToStoryAnimationWidget extends StatefulWidget {
  const TopicsToStoryAnimationWidget({
    super.key,
    this.letters         = const ['A', 'B'],
    this.travelMs        = 2000,
    this.expandMs        = 500,
    this.slideMs         = 400,
    this.cardSize        = const Size(150, 70),
    this.expandedSize    = 300.0,
    this.cardGap         = 12.0,
    this.autoStart       = false,
    this.showDebugPath   = true,
    this.initialAreaSize = const Size(264, 539),
    this.minAreaWidth    = 120,
    this.maxAreaWidth    = 400,
    this.minAreaHeight   = 250,
    this.maxAreaHeight   = 700,
  });

  final List<String> letters;
  final int    travelMs;
  final int    expandMs;
  final int    slideMs;
  final Size   cardSize;
  final double expandedSize;
  final double cardGap;
  final bool   autoStart;
  final bool   showDebugPath;
  final Size   initialAreaSize;
  final double minAreaWidth, maxAreaWidth;
  final double minAreaHeight, maxAreaHeight;

  @override
  State<TopicsToStoryAnimationWidget> createState() =>
      _TopicsToStoryAnimationWidgetState();
}

class _TopicsToStoryAnimationWidgetState
    extends State<TopicsToStoryAnimationWidget>
    with TickerProviderStateMixin {

  // ── geometry — all nullable, built lazily ─────────────────────────
  Size?            _areaSize;
  Path?            _path;
  _ArcLengthTable? _table;
  double           _triggerDist = 0;

  // ── slider values — initialised from widget in initState ──────────
  double _areaWidth  = 264;
  double _areaHeight = 539;

  // ── per-card — initialised in initState ───────────────────────────
  List<_CardState> _cards   = [];
  List<bool>       _started = [];

  int    get _cardCount => widget.letters.length;
  double get _slideStep => widget.expandedSize + widget.cardGap;

  // ── lifecycle ─────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _areaWidth  = widget.initialAreaSize.width;
    _areaHeight = widget.initialAreaSize.height;
    _buildCards();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => play());
    }
  }

  void _buildCards() {
    for (final cs in _cards) cs.dispose();
    _cards   = [];
    _started = List.filled(_cardCount, false);

    for (int i = 0; i < _cardCount; i++) {
      final idx = i;

      final pathCtrl = AnimationController(
        vsync:    this,
        duration: Duration(milliseconds: widget.travelMs),
      );
      final expandCtrl = AnimationController(
        vsync:    this,
        duration: Duration(milliseconds: widget.expandMs),
      );
      final slideCtrl = AnimationController(
        vsync:    this,
        duration: Duration(milliseconds: widget.slideMs),
      );

      final cs = _CardState(
        pathCtrl:   pathCtrl,
        expandCtrl: expandCtrl,
        slideCtrl:  slideCtrl,
      );
      _cards.add(cs);

      pathCtrl.addListener(() => _onPathTick(idx));
      pathCtrl.addStatusListener((s) {
        if (s == AnimationStatus.completed) _onTravelDone(idx);
      });
      expandCtrl.addListener(() { if (mounted) setState(() {}); });
      expandCtrl.addStatusListener((s) {
        if (s == AnimationStatus.completed) _onExpandDone(idx);
      });
      slideCtrl.addListener(() { if (mounted) setState(() {}); });
    }
  }

  // ── phase listeners ───────────────────────────────────────────────

  void _onPathTick(int idx) {
    if (!mounted || _table == null) return;
    final cs = _cards[idx];
    if (!cs.nextTriggered &&
        cs.pathCtrl.value * _table!.totalLength >= _triggerDist) {
      cs.nextTriggered = true;
      _launchCard(idx + 1);
    }
    setState(() {});
  }

  void _onTravelDone(int idx) {
    if (!mounted || _table == null) return;
    // Capture the exact pixel the card was on — avoids any snap on phase switch
    final dist = _table!.totalLength;
    _cards[idx].lastTravelPos = _table!.positionAt(dist);
    setState(() {
      _cards[idx].travelDone = true;
      _cards[idx].expandCtrl.forward();
    });
  }

  void _onExpandDone(int idx) {
    if (!mounted) return;
    setState(() {
      _cards[idx].expandComplete = true;
      // All settled cards (including this one) slide right one step
      for (int i = 0; i <= idx; i++) {
        if (_cards[i].expandComplete) _addSlide(i);
      }
    });
  }

  void _addSlide(int idx) {
    final cs = _cards[idx];
    final current = lerpDouble(
        cs.slideBaseOffset, cs.slideTargetOffset, cs.slideCtrl.value)!;
    cs.slideBaseOffset   = current;
    cs.slideTargetOffset = current + _slideStep;
    cs.slideCtrl.forward(from: 0);
  }

  void _launchCard(int idx) {
    if (idx >= _cardCount || _started[idx]) return;
    _started[idx] = true;
    _cards[idx].pathCtrl.forward();
  }

  void play() {
    for (final cs in _cards) cs.reset();
    _started = List.filled(_cardCount, false);
    _launchCard(0);
  }

  void _ensureGeometry(Size size) {
    if (_areaSize == size && _path != null) return;
    _areaSize    = size;
    _path        = _WaterfallPath.build(size);
    _table       = _ArcLengthTable(_path!);
    _triggerDist = _WaterfallPath.triggerArcLength(size);
    for (final cs in _cards) {
      cs.pathCtrl.duration = Duration(milliseconds: widget.travelMs);
    }
  }

  @override
  void dispose() {
    for (final cs in _cards) cs.dispose();
    super.dispose();
  }

  // ── build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _ensureGeometry(Size(_areaWidth, _areaHeight));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildControls(),
            const Divider(height: 1),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Keep slider values within what the screen can actually show
                  final maxW = constraints.maxWidth;
                  final maxH = constraints.maxHeight;
                  if (_areaWidth  > maxW) WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _areaWidth  = maxW));
                  if (_areaHeight > maxH) WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _areaHeight = maxH));

                  return Center(
                    child: SizedBox(
                      width:  _areaWidth,
                      height: _areaHeight,
                      child: OverflowBox(
                        // Allow cards to draw beyond the SizedBox without clipping
                        maxWidth:  double.infinity,
                        maxHeight: double.infinity,
                        alignment: Alignment.topLeft,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (widget.showDebugPath && _path != null)
                              CustomPaint(
                                size: Size(_areaWidth, _areaHeight),
                                painter: _DebugPathPainter(_path!),
                              ),
                            ...List.generate(_cardCount, _buildCard),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    if (!_started[index] || _table == null) return const SizedBox.shrink();

    final cs    = _cards[index];
    final expS  = widget.expandedSize;
    final cardW = widget.cardSize.width;
    final cardH = widget.cardSize.height;

    if (!cs.travelDone) {
      // Phase 1 — travel along path, original card size, no transforms
      final dist = cs.pathCtrl.value * _table!.totalLength;
      final pos  = _table!.positionAt(dist);
      return Positioned(
        left:   pos.dx - cardW / 2,
        top:    pos.dy - cardH / 2,
        width:  cardW,
        height: cardH,
        child:  _cardWidget(index),
      );
    } else {
      final eased = _smootherstep(cs.expandCtrl.value);

      final slideOffset = lerpDouble(
          cs.slideBaseOffset, cs.slideTargetOffset, cs.slideCtrl.value)!;

      // Use the exact pixel captured at end of travel — no snap
      final startLeft = cs.lastTravelPos.dx - cardW / 2;
      final startTop  = cs.lastTravelPos.dy - cardH / 2;

      final startScale = cardW / expS;
      final scale      = lerpDouble(startScale, 1.0, eased)!;

      return Positioned(
        left:   startLeft + slideOffset,
        top:    startTop,
        width:  expS,
        height: expS,
        child: Transform(
          alignment: Alignment.topLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0008)
            ..scale(scale, scale, 1.0),
          child: _cardWidget(index),
        ),
      );
    }
  }

  Widget _cardWidget(int index) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.yellow,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        widget.letters[index],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(children: [
        Row(children: [
          const SizedBox(width: 60, child: Text('Width')),
          Expanded(
            child: Slider(
              value:     _areaWidth.clamp(widget.minAreaWidth, widget.maxAreaWidth),
              min:       widget.minAreaWidth,
              max:       widget.maxAreaWidth,
              onChanged: (v) => setState(() => _areaWidth = v),
            ),
          ),
          SizedBox(width: 44, child: Text(_areaWidth.toStringAsFixed(0))),
        ]),
        Row(children: [
          const SizedBox(width: 60, child: Text('Height')),
          Expanded(
            child: Slider(
              value:     _areaHeight.clamp(widget.minAreaHeight, widget.maxAreaHeight),
              min:       widget.minAreaHeight,
              max:       widget.maxAreaHeight,
              onChanged: (v) => setState(() => _areaHeight = v),
            ),
          ),
          SizedBox(width: 44, child: Text(_areaHeight.toStringAsFixed(0))),
        ]),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: play,
            icon:  const Icon(Icons.play_arrow),
            label: const Text('Start animation'),
          ),
        ),
      ]),
    );
  }
}

// =====================================================================
// Debug painter
// =====================================================================
class _DebugPathPainter extends CustomPainter {
  _DebugPathPainter(this.path);
  final Path path;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      path,
      Paint()
        ..color       = Colors.red.withOpacity(0.35)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _DebugPathPainter old) => old.path != path;
}