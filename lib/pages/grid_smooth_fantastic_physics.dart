import 'dart:math' as math;

import 'package:flutter/material.dart';

class GridSmoothFantasticGrid extends StatefulWidget {
  const GridSmoothFantasticGrid({super.key});

  @override
  State<GridSmoothFantasticGrid> createState() => _SmoothFantasticGridState();
}

class _SmoothFantasticGridState extends State<GridSmoothFantasticGrid>
    with SingleTickerProviderStateMixin {
  bool showGrid = true;
  late final AnimationController _controller;
  final int itemCount = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_){
      _controller.forward(from: 0);
    });
  }

  void toggleGrid() {
    setState(() {
      showGrid = !showGrid;
      if (showGrid) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smooth Fantastic Grid'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SafeArea(child:
      Column(
        children: [
          const SizedBox(height: 16),
          // ElevatedButton(
          //   onPressed: toggleGrid,
          //   child: Text(showGrid ? 'Hide Grid' : 'Show Grid'),
          // ),
          const SizedBox(height: 16),
          Expanded(
            child: showGrid
                ? GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: itemCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final row = index ~/ 2;
                final col = index % 2;

                // stagger timing
                final start = ((row + col * 0.3) * 0.05).clamp(0.0, 1.0);
                final end = (start + 0.7).clamp(0.0, 1.0);

                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(start, end, curve: Curves.elasticOut),
                );

                // controlled subtle motion
                final offsetX = ((index % 2 == 0 ? -1 : 1) * 40).toDouble(); // ±40px
                final offsetY = 60.0; // slide from bottom
                final rotation = (index % 2 == 0 ? -1 : 1) * (math.pi / 12); // ±15°
                final scaleStart = 0.85;

                // subtle scroll parallax
                final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;
                final parallaxY = math.sin(scrollOffset / 100 + index) * 3;

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        offsetX * (1 - animation.value),
                        offsetY * (1 - animation.value) + parallaxY,
                      ),
                      child: Transform.rotate(
                        angle: rotation * (1 - animation.value),
                        child: Transform.scale(
                          scale: scaleStart + (1 - scaleStart) * animation.value,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  content: Text('Tapped Item $index'),
                                ),
                              );
                            },
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                  child: _GridItem(index),
                );
              },
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),)
    );
  }
}

class _GridItem extends StatelessWidget {
  final int index;
  const _GridItem(this.index);

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blueGrey.shade300,
      Colors.teal.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300
    ];
    return Container(
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        'Item $index',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}


//
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'dart:math' as math;
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   bool showGrid = false;
//   late final AnimationController _controller;
//   final int itemCount = 20;
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1400),
//     );
//   }
//
//   void toggleGrid() {
//     setState(() {
//       showGrid = !showGrid;
//       if (showGrid) {
//         _controller.forward(from: 0);
//       } else {
//         _controller.reverse();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Ultimate Fantastic Grid'), backgroundColor: Colors.lightBlue),
//       body: Column(
//         children: [
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: toggleGrid,
//             child: Text(showGrid ? 'Hide Grid' : 'Show Grid'),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: showGrid
//                 ? GridView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(16),
//               itemCount: itemCount,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 16,
//               ),
//               itemBuilder: (context, index) {
//                 final row = index ~/ 2;
//                 final col = index % 2;
//
//                 // Stagger timing based on row + column
//                 final start = (row + col * 0.3) * 0.05;
//                 final end = start + 0.7;
//
//                 // springy entry animation
//                 final animation = CurvedAnimation(
//                   parent: _controller,
//                   curve: Interval(
//                     start.clamp(0.0, 1.0),
//                     end.clamp(0.0, 1.0),
//                     curve: Curves.elasticOut,
//                   ),
//                 );
//
//                 // Random slide direction
//                 final directions = [
//                   Offset(-1, 1),
//                   Offset(1, 1),
//                   Offset(-1, -1),
//                   Offset(1, -1)
//                 ];
//                 final direction = directions[index % directions.length];
//
//                 // Full rotation ±180 degrees
//                 final initialRotation = math.pi * (math.Random(index).nextBool() ? 1 : -1);
//
//                 // Scroll parallax offset
//                 final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;
//                 final parallaxY = sin(scrollOffset / 100 + index) * 5;
//
//                 return AnimatedBuilder(
//                   animation: animation,
//                   builder: (context, child) {
//                     return Transform.translate(
//                       offset: Offset(
//                           direction.dx * 120 * (1 - animation.value),
//                           direction.dy * 120 * (1 - animation.value) + parallaxY),
//                       child: Transform.rotate(
//                         angle: initialRotation * (1 - animation.value),
//                         child: Transform.scale(
//                           scale: 0.7 + 0.3 * animation.value,
//                           child: GestureDetector(
//                             onTap: () {
//                               // small pop on tap
//                               showDialog(
//                                 context: context,
//                                 builder: (_) => AlertDialog(
//                                   content: Text('Tapped Item $index'),
//                                 ),
//                               );
//                             },
//                             child: child,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   child: _GridItem(index),
//                 );
//               },
//             )
//                 : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _GridItem extends StatelessWidget {
//   final int index;
//   const _GridItem(this.index);
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = [Colors.blueGrey.shade300, Colors.teal.shade300, Colors.orange.shade300];
//     return Container(
//       decoration: BoxDecoration(
//         color: colors[index % colors.length],
//         borderRadius: BorderRadius.circular(16),
//       ),
//       alignment: Alignment.center,
//       child: Text('Item $index', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//     );
//   }
// }
//
