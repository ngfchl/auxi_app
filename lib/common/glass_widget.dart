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
          StringUtils.getLottieByName('五彩纸屑'),
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
          blur: 4,
          color: Colors.white.withOpacity(0.01),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.withOpacity(0.2),
              Colors.blue.withOpacity(0.3),
            ],
          ),
          //--code to remove border
          border: const Border.fromBorderSide(BorderSide.none),
          shadowStrength: 5,
          shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(16),
          shadowColor: Colors.white.withOpacity(0.24),
          child: child,
        ),
      ],
    );
  }
}
