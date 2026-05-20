import 'package:flutter/material.dart';

class CustomHeroAnimation extends StatefulWidget {
  const CustomHeroAnimation({super.key});

  @override
  State<CustomHeroAnimation> createState() => _CustomHeroAnimationState();
}

class _CustomHeroAnimationState extends State<CustomHeroAnimation> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _greenKey = GlobalKey();
  final GlobalKey _redKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  Future<void> _animateBoxes() async {
    final greenBox = _greenKey.currentContext?.findRenderObject() as RenderBox?;
    if (greenBox == null) return;

    final greenPos = greenBox.localToGlobal(Offset.zero);
    final greenSize = greenBox.size;

    final animController = AnimationController(
      vsync: Navigator.of(context).overlay!,
      duration: const Duration(milliseconds: 1200),
    );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _FloatingBox(
          controller: animController,
          startOffset: greenPos,
          startSize: greenSize,
          redKey: _redKey,
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    _scrollController.animateTo(
      MediaQuery.of(context).size.height -
          MediaQuery.viewPaddingOf(context).top,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutCubic,
    );

    animController.forward();

    await Future.delayed(const Duration(milliseconds: 1300));
    _overlayEntry?.remove();
    _overlayEntry = null;
    animController.dispose();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height -
        MediaQuery.viewPaddingOf(context).top;

    return Scaffold(
      body: ListView(
        controller: _scrollController,
        children: [
          PageOne(
            height: height,
            greenKey: _greenKey,
            callback: _animateBoxes,
          ),
          PageTwo(height: height, redKey: _redKey),
        ],
      ),
    );
  }
}

// ─── Floating Box ─────────────────────────────────────────────────────────────

class _FloatingBox extends StatefulWidget {
  final AnimationController controller;
  final Offset startOffset;
  final Size startSize;
  final GlobalKey redKey;

  const _FloatingBox({
    required this.controller,
    required this.startOffset,
    required this.startSize,
    required this.redKey,
  });

  @override
  State<_FloatingBox> createState() => _FloatingBoxState();
}

class _FloatingBoxState extends State<_FloatingBox> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() => setState(() {});

  Offset _getCurrentRedOffset() {
    final redBox =
    widget.redKey.currentContext?.findRenderObject() as RenderBox?;
    if (redBox == null) return widget.startOffset;
    return redBox.localToGlobal(Offset.zero);
  }

  Size _getCurrentRedSize() {
    final redBox =
    widget.redKey.currentContext?.findRenderObject() as RenderBox?;
    return redBox?.size ?? const Size(200, 200);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.controller.value;
    final easedT = Curves.easeInOutCubic.transform(t);

    final endOffset = _getCurrentRedOffset();
    final endSize = _getCurrentRedSize();

    // Arc lift peaks at t=0.5
    final arcLift = Offset(0, -150 * 4 * easedT * (1 - easedT));
    final rawPos =
        Offset.lerp(widget.startOffset, endOffset, easedT)! + arcLift;

    final sz = Size.lerp(widget.startSize, endSize, easedT)!;
    final color = Color.lerp(Colors.green, Colors.red, easedT)!;
    final shadowBlur = 8.0 + 20.0 * easedT;
    final shadowOffset = Offset(0, 4.0 + 8.0 * easedT);

    // Bounce squish on landing (last 15% of raw t)
    double bounce = 1.0;
    if (t > 0.85) {
      final lt = (t - 0.85) / 0.15;
      bounce = 1.0 - 0.18 * (4 * lt * (1 - lt));
    }

    return Positioned(
      left: rawPos.dx,
      top: rawPos.dy,
      child: Transform.scale(
        scale: bounce,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: sz.width,
          height: sz.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12 * (1 - easedT)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: shadowBlur,
                offset: shadowOffset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pages ────────────────────────────────────────────────────────────────────

class PageOne extends StatelessWidget {
  final double height;
  final VoidCallback callback;
  final GlobalKey greenKey;

  const PageOne({
    super.key,
    required this.height,
    required this.callback,
    required this.greenKey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 100),
          GestureDetector(
            onTap: callback,
            child: Container(
              key: greenKey,
              width: 100,
              height: 100,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class PageTwo extends StatelessWidget {
  final double height;
  final GlobalKey redKey;

  const PageTwo({super.key, required this.height, required this.redKey});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 100),
          Container(
            key: redKey,
            width: 200,
            height: 200,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}