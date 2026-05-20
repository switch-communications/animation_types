import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

class SpringPagePhysics extends PageScrollPhysics {
  final MotionProfile profile;

  const SpringPagePhysics({
    required this.profile,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  SpringPagePhysics applyTo(ScrollPhysics? ancestor) {
    return SpringPagePhysics(
      profile: profile,
      parent: buildParent(ancestor),
    );
  }

  SpringDescription get springDescription => profile.spring;
}
