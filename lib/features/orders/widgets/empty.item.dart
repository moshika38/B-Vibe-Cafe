import 'package:flutter/material.dart';

class EmptyItem extends StatelessWidget {
  const EmptyItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF5F1EC),
              border: Border.all(
                color: const Color(0xFFEAE7E3),
              ),
            ),
            child: Center(
              child: Image.asset(
                "assets/img/empty.png",
                width: 40,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.inbox_outlined,
                  size: 40,
                  color: Color(0xFFA8A29E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No Items",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B6560),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "This section is empty",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFFA8A29E),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
