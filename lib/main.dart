import 'package:animation_types/home_screen.dart';
import 'package:animation_types/utils/no_overscroll_indicator.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/physics.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      scrollBehavior: NoOverscrollIndicator(),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}



