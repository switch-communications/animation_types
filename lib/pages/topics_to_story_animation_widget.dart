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

    final seg1and2 = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1a.dx, c1a.dy, c1b.dx, c1b.dy, e1.dx, e1.dy)
      ..cubicTo(c2a.dx, c2a.dy, c2b.dx, c2b.dy, e2.dx, e2.dy);

    return seg1and2.computeMetrics().first.length;
  }
}

class _ArcLengthTable {
  // Increased samples to 500 for high-density precision tracking
  _ArcLengthTable(Path path, {this.samples = 500}) {
    final metric  = path.computeMetrics().first;
    totalLength   = metric.length;
    final safeLen = totalLength - 0.01;
    _points = List<Offset>.generate(samples + 1, (i) {
      final d = (safeLen * i / samples).clamp(0, safeLen);
      return metric.getTangentForOffset(d.toDouble())!.position;
    });
  }

  final int    samples;
  double       totalLength = 0;
  List<Offset> _points     = [];

  // FIX: Jolt-free progressive positioning math using raw fractional lookups
  Offset positionAtProgress(double t) {
    if (_points.isEmpty) return Offset.zero;
    final double exactIndexFraction = t.clamp(0.0, 1.0) * samples;
    final int index = exactIndexFraction.floor().clamp(0, samples - 1);
    final double remainder = exactIndexFraction - index;
    return Offset.lerp(_points[index], _points[index + 1], remainder)!;
  }

  Offset get endPosition => _points.isEmpty ? Offset.zero : _points[samples];
}

double _smootherstep(double t) {
  final x = t.clamp(0.0, 1.0);
  return x * x * x * (x * (x * 6 - 15) + 10);
}

// =====================================================================
// Per-card simplified state
// =====================================================================
class _CardState {
  _CardState({
    required this.mainCtrl,
    required this.pushCtrl,
  });

  final AnimationController mainCtrl;
  final AnimationController pushCtrl;

  bool nextTriggered = false;
  bool pushDone      = false;

  void dispose() {
    mainCtrl.dispose();
    pushCtrl.dispose();
  }

  void reset() {
    mainCtrl.reset();
    pushCtrl.reset();
    nextTriggered = false;
    pushDone      = false;
  }
}

// =====================================================================
// Widget
// =====================================================================
class TopicsToStoryAnimationWidget extends StatefulWidget {
  const TopicsToStoryAnimationWidget({
    super.key,
    this.letters         = const ['A', 'B', 'C', 'D'],
    this.totalJourneyMs  = 2200,
    this.slideMs         = 500,
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
  final int    totalJourneyMs;
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

  Size?            _areaSize;
  Path?            _path;
  _ArcLengthTable? _table;
  double           _triggerDist = 0;

  double _areaWidth  = 120;
  double _areaHeight = 250;

  List<_CardState> _cards   = [];
  List<bool>       _started = [];

  int    get _cardCount => widget.letters.length;
  double get _slideStep => widget.expandedSize + widget.cardGap;

  // Custom deceleration velocity mapping curve curve
  double _getBurstCurve(double t) {
    return t * (2.0 - t);
  }

  bool get _allSettled {
    if (_cards.isEmpty) return false;
    for (int i = 0; i < _cardCount; i++) {
      if (!_cards[i].mainCtrl.isCompleted) return false;
      if (i < _cardCount - 1 && !_cards[i].pushDone) return false;
    }
    return true;
  }

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

      final mainCtrl = AnimationController(
        vsync:    this,
        duration: Duration(milliseconds: widget.totalJourneyMs),
      );
      final pushCtrl = AnimationController(
        vsync:    this,
        duration: Duration(milliseconds: widget.slideMs),
      );

      final cs = _CardState(
        mainCtrl: mainCtrl,
        pushCtrl: pushCtrl,
      );
      _cards.add(cs);

      mainCtrl.addListener(() => _onMainTick(idx));
      mainCtrl.addStatusListener((s) {
        if (s == AnimationStatus.completed) _onMainJourneyDone(idx);
      });
      pushCtrl.addStatusListener((s) {
        if (s == AnimationStatus.completed) _onPushDone(idx);
      });
    }
  }

  void _onMainTick(int idx) {
    if (!mounted || _table == null) return;
    final cs = _cards[idx];

    final double pathProgress = _getBurstCurve(cs.mainCtrl.value);

    if (!cs.nextTriggered && pathProgress * _table!.totalLength >= _triggerDist) {
      cs.nextTriggered = true;
      _launchCard(idx + 1);
    }
    setState(() {});
  }

  void _onMainJourneyDone(int idx) {
    if (!mounted) return;
    if (idx < _cardCount - 1) {
      _cards[idx].pushCtrl.forward(from: 0);
    }
  }

  void _onPushDone(int idx) {
    if (!mounted) return;
    setState(() => _cards[idx].pushDone = true);
  }

  double _currentOffsetFor(int i) {
    double offset = 0.0;
    for (int k = i; k < _cardCount; k++) {
      if (k == _cardCount - 1) continue;
      final ck = _cards[k];
      if (!ck.mainCtrl.isCompleted && ck.mainCtrl.value < 0.65) continue;
      if (ck.pushDone) {
        offset += _slideStep;
      } else {
        offset += _slideStep * _smootherstep(ck.pushCtrl.value);
      }
    }
    return offset;
  }

  void _launchCard(int idx) {
    if (idx >= _cardCount || _started[idx]) return;
    _started[idx] = true;
    _cards[idx].mainCtrl.forward();
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
    _triggerDist = _WaterfallPath.triggerArcLength(size) + 15.0;
  }

  @override
  void dispose() {
    for (final cs in _cards) cs.dispose();
    super.dispose();
  }

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
                  final maxW = constraints.maxWidth;
                  final maxH = constraints.maxHeight;
                  if (_areaWidth  > maxW) WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _areaWidth  = maxW));
                  if (_areaHeight > maxH) WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _areaHeight = maxH));

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        for (final cs in _cards) ...[cs.mainCtrl, cs.pushCtrl],
                      ]),
                      builder: (context, _) {
                        final shiftX = _areaWidth > maxW ? 0.0 : (maxW - _areaWidth) / 2;
                        final shiftY = maxH > _areaHeight ? (maxH - _areaHeight) / 2 : 0.0;
                        final boxHeight = maxH > _areaHeight ? maxH : _areaHeight;

                        final contentW = _contentWidthLocal(shiftX);
                        final boxWidth = contentW > maxW ? contentW : maxW;

                        return SizedBox(
                          width:  boxWidth,
                          height: boxHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (widget.showDebugPath && _path != null && !_allSettled)
                                Positioned(
                                  left: shiftX,
                                  top:  shiftY,
                                  child: CustomPaint(
                                    size:    Size(_areaWidth, _areaHeight),
                                    painter: _DebugPathPainter(_path!),
                                  ),
                                ),
                              ...List.generate(_cardCount, (i) => _buildCard(i, shiftX, shiftY)),
                            ],
                          ),
                        );
                      },
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

  double _contentWidthLocal(double shiftX) {
    if (_table == null || _cardCount == 0) return _areaWidth;
    final endPos  = _table!.endPosition;
    final cardW   = widget.cardSize.width;
    final expS    = widget.expandedSize;
    final offset0 = _currentOffsetFor(0);
    final rightEdge = shiftX + (endPos.dx - cardW / 2) + offset0 + expS + (cardW / 2);
    return rightEdge > _areaWidth ? rightEdge : _areaWidth;
  }

  Widget _buildCard(int index, double shiftX, double shiftY) {
    if (!_started[index] || _table == null) return const SizedBox.shrink();

    final cs    = _cards[index];
    final expS  = widget.expandedSize;
    final cardW = widget.cardSize.width;
    final cardH = widget.cardSize.height;

    final double rawProgress = cs.mainCtrl.value;

    final double movementProgress = _getBurstCurve(rawProgress);
    final Offset pathPos = _table!.positionAtProgress(movementProgress);

    double scaleFactor = 0.0;
    if (rawProgress >= 0.65) {
      final double normalizedScaleProgress = (rawProgress - 0.65) / 0.35;
      scaleFactor = _smootherstep(normalizedScaleProgress);
    }

    final double currentW = cardW + (expS - cardW) * scaleFactor;
    final double currentH = cardH + (expS - cardH) * scaleFactor;

    final double horizontalOffset = _currentOffsetFor(index);

    // CHANGED: Instead of keeping top-anchor static, we subtract half of the total height delta
    // gained during expansion. This forces the card to expand upwards and downwards at the exact same rate.
    final double heightDelta = currentH - cardH;
    final double verticalAnchorCorrection = heightDelta / 2;

    return Positioned(
      left:   shiftX + (pathPos.dx - cardW / 2) + horizontalOffset,
      top:    shiftY + (pathPos.dy - cardH / 2) - verticalAnchorCorrection,
      width:  currentW,
      height: currentH,
      child:  _cardWidget(index),
    );
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