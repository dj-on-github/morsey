import 'package:flutter/material.dart';

/// A compact tap keyboard for touch platforms.
///
/// The listening trainers take answers from hardware [KeyEvent]s, so on
/// iOS/Android there is nothing to type on: no text field means the system
/// soft keyboard never appears (and iPadOS suppresses it anyway while the USB
/// key is plugged in, because the key enumerates as a hardware keyboard).
/// This widget provides the missing keys; taps feed the same answer path the
/// hardware keyboard uses.
class OnScreenKeyboard extends StatelessWidget {
  const OnScreenKeyboard({super.key, required this.onKey, this.characters});

  /// Called with the tapped character (upper case, length 1).
  final ValueChanged<String> onKey;

  /// If given, only these characters are shown and rows left with no keys
  /// collapse — so a numbers-only drill shows a single digit row. Null shows
  /// the full layout.
  final Set<String>? characters;

  static const List<List<String>> _fullRows = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ['.', ',', '?', '!', '/', '=', '+', '-', '@'],
    ["'", '(', ')', '&', ':', ';', '_', '"'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = [
      for (final row in _fullRows)
        [
          for (final k in row)
            if (characters?.contains(k) ?? true) k,
        ],
    ].where((r) => r.isNotEmpty).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Size keys so the widest row fits; keep them finger-sized.
        final widest =
            rows.fold<int>(1, (m, r) => r.length > m ? r.length : m);
        final keyW =
            ((constraints.maxWidth - 8) / widest - 4).clamp(26.0, 56.0);
        final keyH = (keyW * 1.15).clamp(34.0, 48.0);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in rows)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [for (final k in row) _key(theme, k, keyW, keyH)],
              ),
          ],
        );
      },
    );
  }

  Widget _key(ThemeData theme, String k, double w, double h) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onKey(k),
          child: SizedBox(
            width: w,
            height: h,
            child: Center(
              child: Text(k, style: theme.textTheme.titleMedium),
            ),
          ),
        ),
      ),
    );
  }
}
