import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key, this.height = 16, this.width = double.infinity, this.borderRadius = 8});

  final double height;
  final double width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);
    final highlight = Theme.of(context).colorScheme.onSurface.withOpacity(0.12);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
