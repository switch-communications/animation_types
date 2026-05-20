import 'package:animation_types/widget/physics_controllers.dart';
import 'package:flutter/material.dart';

class SpringyScrollPhysics extends BouncingScrollPhysics {
  final MotionProfile profile;

   SpringyScrollPhysics({
    required this.profile,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  SpringDescription get spring => SpringDescription(
    mass: profile.mass,
    stiffness: profile.stiffness,
    damping: profile.damping,
  );

  @override
  SpringyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SpringyScrollPhysics(
      profile: profile,
      parent: buildParent(ancestor),
    );
  }
}
