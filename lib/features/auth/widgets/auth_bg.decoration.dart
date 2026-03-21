import 'package:flutter/material.dart';
import 'package:bvibe/const/theme.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class AuthBgDecoration extends StatelessWidget {
  const AuthBgDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid base color
        Container(color: AppColors.background),
        
        // Top-left decorative blob
        Positioned(
          top: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 4.seconds)
           .move(begin: const Offset(0, 0), end: const Offset(20, 20), duration: 5.seconds),
        ),

        // Bottom-right decorative blob
        Positioned(
          bottom: -200,
          right: -100,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 5.seconds)
           .move(begin: const Offset(0, 0), end: const Offset(-30, -20), duration: 6.seconds),
        ),

        // Blur overlay to make blobs look like gradient meshes
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}
