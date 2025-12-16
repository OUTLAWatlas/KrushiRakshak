import 'package:flutter/material.dart';

class CropTimelineCard extends StatelessWidget {
  const CropTimelineCard({
    super.key,
    required this.cropName,
    required this.sowingDate,
    required this.totalDuration,
    required this.variety,
  });

  final String cropName;
  final DateTime sowingDate;
  final int totalDuration;
  final String variety;

  int _daysElapsed() {
    final now = DateTime.now();
    final diff = now.difference(sowingDate).inDays;
    return diff < 0 ? 0 : diff;
  }

  double _progress(int daysElapsed) {
    if (totalDuration <= 0) return 0;
    final ratio = daysElapsed / totalDuration;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }

  String _currentStage(int daysElapsed) {
    if (daysElapsed < 40) return 'Vegetative';
    if (daysElapsed < 90) return 'Flowering';
    return 'Harvest';
  }

  Color _stageColor(String stage, BuildContext context) {
    switch (stage) {
      case 'Vegetative':
        return Colors.green.shade600;
      case 'Flowering':
        return Colors.pink.shade400;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _advisory(String stage) {
    switch (stage) {
      case 'Vegetative':
        return 'Monitor sucking pests and early weeds';
      case 'Flowering':
        return 'Pink Bollworm risk—scout frequently';
      default:
        return 'Prepare for picking and field sanitation';
    }
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _daysElapsed();
    final stage = _currentStage(elapsed);
    final progressValue = _progress(elapsed);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Variety: $variety',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Chip(
                  backgroundColor:
                      _stageColor(stage, context).withOpacity(stage == 'Harvest' ? 0.15 : 0.2),
                  side: BorderSide.none,
                  label: Text(
                    stage,
                    style: TextStyle(
                      color: stage == 'Harvest'
                          ? Theme.of(context).colorScheme.outline
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 10,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Day $elapsed of $totalDuration',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Advisory: ${_advisory(stage)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
