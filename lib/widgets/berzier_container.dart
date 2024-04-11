import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes_app/utils/size_config.dart';

import 'package:notes_app/widgets/custom_clipper.dart';

class BezierContainer extends StatelessWidget {
  const BezierContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -pi / 3.5,
      child: ClipPath(
        clipper: ClipPainter(),
        child: Container(
          height: SizeConfig.screenHeight * 0.5,
          width: SizeConfig.screenWidth,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xfffbb448), Color(0xffe46b10)])),
        ),
      ),
    );
  }
}
