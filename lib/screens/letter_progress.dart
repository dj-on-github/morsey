import 'package:flutter/material.dart';

/// A compact chip showing one letter's mastery progress (filled dots).
/// Shared by the Listen and Input tutorial screens.
class LetterProgress extends StatelessWidget {
  const LetterProgress({
    super.key,
    required this.letter,
    required this.count,
    required this.target,
    required this.isNew,
  });

  final String letter;
  final int count;
  final int target;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = count >= target;
    final border = done
        ? Colors.green
        : (isNew ? theme.colorScheme.primary : theme.colorScheme.outlineVariant);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: border, width: isNew ? 2 : 1),
        borderRadius: BorderRadius.circular(8),
        color: done ? Colors.green.withValues(alpha: 0.12) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(letter,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < target; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Icon(
                    i < count ? Icons.circle : Icons.circle_outlined,
                    size: 8,
                    color: i < count
                        ? Colors.green
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
