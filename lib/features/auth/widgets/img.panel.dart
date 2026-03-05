import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ImgPanel extends StatelessWidget {
  const ImgPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset('assets/img/login_page.jpg', fit: BoxFit.cover),

        // Gradient overlay at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 80, 32, 36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand name row
                Row(
                  children: [
                    const Icon(Icons.restaurant, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Lumina POS',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Elevating the dining experience through\nseamless service.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }
}