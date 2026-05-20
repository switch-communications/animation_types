import 'package:flutter/material.dart';
import 'dart:ui';

// --- 1. THE PHYSICS ENGINE BRIDGE ---
class MotionProfile {
  double mass;
  double stiffness;
  double damping;
  double drag;

  MotionProfile({
    this.mass = 1.0,
    this.stiffness = 300.0,
    this.damping = 10.0,
    this.drag = 0.15,
  });

  SpringDescription get springDesc => SpringDescription(
    mass: mass,
    stiffness: stiffness,
    damping: damping + (drag * 40),
  );

  Duration get dynamicDuration {
    double ms = (mass * 1000) / (stiffness / 100);
    return Duration(milliseconds: ms.toInt().clamp(100, 2000));
  }

  Curve get dynamicCurve {
    if (damping < 12) return Curves.elasticOut; // Bouncy
    if (damping < 25) return Curves.easeOutBack; // Overshoot
    return Curves.easeOutQuart; // Smooth
  }
}


class PhysicsTabsLab extends StatefulWidget {
  const PhysicsTabsLab({super.key});

  @override
  State<PhysicsTabsLab> createState() => _PhysicsTabsLabState();
}

class _PhysicsTabsLabState extends State<PhysicsTabsLab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MotionProfile _profile = MotionProfile();
  String _selectedTabType = 'Magnetic Bubble';

  final List<String> _categories = [
    'Magnetic Bubble', 'Liquid Stretch', 'Neon Glow', 'Glass Floating',
    'Depth Inset', 'Minimal Dot', 'Capsule Pill', 'Underline Bold',
    'Double Line', 'Block Slide', 'Soft Shadow', 'Outline Border',
    'Retro Pixel', 'Indicator Scale', 'Vertical Dash', 'Square Punch',
    'Holographic', 'Floating Island', 'Skewed Tabs', 'Gradient Wave'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text("Tabs"), elevation: 0),
      body: Column(
        children: [
          _buildDropdownHeader(),
          const SizedBox(height: 20),
          _buildSelectedTabStyle(),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PhysicsControls(profile: _profile, onChanged: () => setState(() {})),
                    const Divider(),
                    SizedBox(
                      height: 200,
                      child: TabBarView(
                        controller: _tabController,
                        physics: CustomSpringPhysics(customSpring: _profile.springDesc),
                        children: [
                          _page(Colors.indigo, Icons.rocket_launch),
                          _page(Colors.purple, Icons.auto_awesome),
                          _page(Colors.cyan, Icons.waves),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: DropdownButtonFormField<String>(
        value: _selectedTabType,
        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _selectedTabType = v!),
      ),
    );
  }

  // --- DYNAMIC PHYSICS-LINKED STYLES ---
  Widget _buildSelectedTabStyle() {
    switch (_selectedTabType) {
      case 'Magnetic Bubble': return _wrapper(_magneticIndicator());
      case 'Liquid Stretch': return _wrapper(_liquidIndicator());
      case 'Neon Glow': return _wrapper(_neonIndicator(), color: Colors.black);
      case 'Glass Floating': return _wrapper(_glassIndicator(), color: Colors.blueGrey[100]);
      case 'Depth Inset': return _depthInset();
      case 'Minimal Dot': return _wrapper(_dotIndicator());
      case 'Capsule Pill': return _wrapper(_capsuleIndicator());
      case 'Underline Bold': return _wrapper(_underlineBoldIndicator());
      case 'Double Line': return _wrapper(_doubleLineIndicator());
      case 'Block Slide': return _wrapper(_blockIndicator());
      case 'Soft Shadow': return _wrapper(_shadowIndicator());
      case 'Outline Border': return _wrapper(_outlineIndicator());
      case 'Indicator Scale': return _wrapper(_scaleIndicator());
      case 'Retro Pixel': return _wrapper(_pixelIndicator(), color: Colors.grey[900]);
      case 'Floating Island': return _wrapper(_floatingIndicator(), margin: 12);
      case 'Vertical Dash': return _wrapper(_dashIndicator());
      case 'Square Punch': return _wrapper(_squareIndicator());
      case 'Skewed Tabs': return _wrapper(_skewedIndicator());
      case 'Gradient Wave': return _wrapper(_gradientIndicator());
      case 'Holographic': return _wrapper(_holographicIndicator());
      default: return _wrapper(_magneticIndicator());
    }
  }

  Widget _wrapper(Widget indicator, {Color? color, double margin = 0}) {
    return Container(
      width: 330, height: 60,
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(color: color ?? Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          indicator,
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            labelColor: (color == Colors.black || color == Colors.grey[900]) ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.black38,
            tabs: const [Tab(text: "A"), Tab(text: "B"), Tab(text: "C")],
          ),
        ],
      ),
    );
  }

  // --- ALL 20 INDICATORS ---
  Widget _magneticIndicator() => _anim(child: Container(margin: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))));

  Widget _liquidIndicator() => AnimatedPadding(
    duration: _profile.dynamicDuration, curve: _profile.dynamicCurve,
    padding: EdgeInsets.only(left: _tabController.index * 110.0),
    child: Container(width: 110, height: 4, margin: const EdgeInsets.only(top: 50), color: Colors.blue),
  );

  Widget _neonIndicator() => _anim(child: Container(margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), decoration: BoxDecoration(color: Colors.cyanAccent, boxShadow: [BoxShadow(color: Colors.cyanAccent, blurRadius: 15 + (_profile.drag * 30))])));

  Widget _glassIndicator() => _anim(child: Container(margin: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white70))));

  Widget _dotIndicator() => _anim(alignmentY: 0.8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)));

  Widget _capsuleIndicator() => _anim(child: Container(decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(30))));

  Widget _underlineBoldIndicator() => _anim(alignmentY: 1, child: Container(width: 60, height: 5, color: Colors.black));

  Widget _doubleLineIndicator() => Stack(children: [
    _anim(alignmentY: -1, child: Container(width: 40, height: 3, color: Colors.blue)),
    _anim(alignmentY: 1, child: Container(width: 40, height: 3, color: Colors.blue)),
  ]);

  Widget _blockIndicator() => _anim(child: Container(color: Colors.indigo.withOpacity(0.8)));

  Widget _shadowIndicator() => _anim(child: Container(margin: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))])));

  Widget _outlineIndicator() => _anim(child: Container(margin: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2), borderRadius: BorderRadius.circular(8))));

  Widget _scaleIndicator() => _anim(child: AnimatedScale(scale: 0.8 + (_profile.mass * 0.2), duration: const Duration(milliseconds: 200), child: Container(decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle))));

  Widget _pixelIndicator() => _anim(child: Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(border: Border.all(color: Colors.greenAccent, width: 3), color: Colors.greenAccent.withOpacity(0.2))));

  Widget _floatingIndicator() => _anim(child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)])));

  Widget _dashIndicator() => _anim(alignmentY: 0.9, child: Container(width: 20, height: 4, color: Colors.blue));

  Widget _squareIndicator() => _anim(child: Container(margin: const EdgeInsets.all(10), decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2))));

  Widget _holographicIndicator() => _anim(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.3), Colors.purple.withOpacity(0.3), Colors.cyan.withOpacity(0.3)]))));

  Widget _skewedIndicator() => _anim(child: Transform(transform: Matrix4.skewX(-0.2), child: Container(color: Colors.blue.withOpacity(0.2))));

  Widget _gradientIndicator() => _anim(child: Container(margin: const EdgeInsets.only(top: 50), height: 4, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.blue, Colors.purple, Colors.red]))));

  Widget _depthInset() => _wrapper(
    _anim(child: Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 5), BoxShadow(color: Colors.black12, offset: Offset(3, 3), blurRadius: 5)]))),
    color: const Color(0xFFF0F2F5),
  );

  // --- HELPER ANIMATION WIDGET ---
  Widget _anim({required Widget child, double alignmentY = 0}) {
    return AnimatedAlign(
      duration: _profile.dynamicDuration,
      curve: _profile.dynamicCurve,
      alignment: Alignment((_tabController.index - 1).toDouble(), alignmentY),
      child: FractionallySizedBox(widthFactor: 0.33, child: child),
    );
  }

  Widget _page(Color c, IconData i) => Container(margin: const EdgeInsets.all(15), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20)), child: Icon(i, size: 50, color: Colors.white));
}

// --- 2. THE FIXED PHYSICS CLASS ---
class CustomSpringPhysics extends ScrollPhysics {
  final SpringDescription customSpring;
  const CustomSpringPhysics({required this.customSpring, super.parent});
  @override
  CustomSpringPhysics applyTo(ScrollPhysics? ancestor) => CustomSpringPhysics(customSpring: customSpring, parent: buildParent(ancestor));
  @override
  SpringDescription get spring => customSpring;
}

// --- 3. PHYSICS CONTROLS ---
class PhysicsControls extends StatelessWidget {
  final MotionProfile profile;
  final VoidCallback onChanged;
  const PhysicsControls({super.key, required this.profile, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _sl("Mass", profile.mass, 0.5, 3.0, (v) => profile.mass = v),
          _sl("Stiffness", profile.stiffness, 50, 600, (v) => profile.stiffness = v),
          _sl("Damping", profile.damping, 1, 40, (v) => profile.damping = v),
          _sl("Drag", profile.drag, 0.02, 0.5, (v) => profile.drag = v),
        ],
      ),
    );
  }

  Widget _sl(String label, double val, double min, double max, Function(double) update) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${val.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Slider(value: val, min: min, max: max, onChanged: (v) { update(v); onChanged(); }),
      ],
    );
  }
}