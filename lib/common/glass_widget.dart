import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:lottie/lottie.dart';

import '../utils/string_utils.dart';

class GlassWidget extends StatelessWidget {
  const GlassWidget({Key? key, required Widget this.child}) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Lottie.asset(
          StringUtils.getLottieByName('rJoSLquA8J'),
          repeat: true,
          fit: BoxFit.fill,
        ),
        // GlassmorphicContainer(
        //   width: double.infinity,
        //   height: double.infinity,
        //   borderRadius: 0,
        //   linearGradient: LinearGradient(
        //       colors: [
        //         const Color(0xFFFFFFFF).withOpacity(0.1),
        //         const Color(0xFFFFFFFF).withOpacity(0.05),
        //       ],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //       stops: const [
        //         0.01,
        //         0.1,
        //       ]),
        //   border: 0,
        //   blur: 20,
        //   borderGradient: LinearGradient(
        //       colors: [
        //         const Color(0xFFFFFFFF).withOpacity(0.1),
        //         const Color(0xFFFFFFFF).withOpacity(0.05),
        //       ],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //       stops: const [
        //         0.1,
        //         1,
        //       ]),
        //   child: child!,
        // )
        GlassContainer(
          height: double.infinity,
          width: double.infinity,
          blur: 1,
          color: Colors.white.withOpacity(0.9999999),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueGrey.withOpacity(0.5),
              Colors.blueGrey.withOpacity(0.6),
              Colors.grey.withOpacity(0.4),
              Colors.black12.withOpacity(0.6),
            ],
          ),
          //--code to remove border
          border: const Border.fromBorderSide(BorderSide.none),
          shadowStrength: 5,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(2),
          shadowColor: Colors.white.withOpacity(0.24),
          child: child,
        ),
      ],
    );
  }
}
