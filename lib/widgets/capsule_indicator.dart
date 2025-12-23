import 'package:flutter/material.dart';

class CapsuleIndicator extends StatelessWidget {
  const CapsuleIndicator({
    super.key,
    required this.percent,
    this.height = 120,
    this.width = 64,
    this.backgroundColor = const Color(0xFFEEEEEE),
    this.fillColor = const Color(0xFF4CAF50),
  });

  final double percent; // 0.0 - 1.0
  final double height;
  final double width;
  final Color backgroundColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0);
    // Reserve a small padding so the fill never overflows the capsule outline
    final availableHeight = height - 8; // top/bottom padding
    final innerHeight = (availableHeight * clamped).clamp(0.0, availableHeight);

    // For very small fills show a subtle rounded strip instead of overflowing
    final displayHeight = clamped > 0 && innerHeight < 4 ? 4.0 : innerHeight;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Capsule outer with subtle shadow for 3D look
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundColor.withOpacity(0.98), backgroundColor.withOpacity(0.9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(width / 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 4)),
                BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 1, offset: const Offset(0, -1)),
              ],
            ),
          ),
          // Filled portion aligned to bottom with rounded top
          if (clamped > 0)
            Positioned(
              bottom: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular((width - 8) / 2),
                child: Container(
                  width: width - 8,
                  height: displayHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [fillColor.withOpacity(0.95), fillColor.withOpacity(0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                ),
              ),
            ),
          // Glass highlight
          Positioned(
            top: 6,
            child: Container(
              width: width - 12,
              height: height * 0.18,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.35), Colors.white.withOpacity(0.06)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Percentage text inside capsule (small and subtle)
          Positioned(
            bottom: 6,
            child: Text(
              '${(clamped * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
