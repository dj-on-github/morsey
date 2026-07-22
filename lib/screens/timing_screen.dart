import 'dart:math';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../input/combined_paddle_source.dart';
import '../l10n/gen/app_localizations.dart';
import '../l10n/status_l10n.dart';
import '../models/settings.dart';
import '../morsey/iambic_keyer.dart';
import '../morsey/morse_code.dart';
import '../morsey/sample_lines.dart';
import 'page_scaffold.dart';

/// Shows a line of text with its Morse; the operator keys the line and the
/// timing of every pulse and gap is measured against the expected sequence.
///
/// Alignment is per CHARACTER, using the keyer's own decode: each pattern
/// the keyer commits is compared with the expected letter. A match accepts
/// the character's buffered timings into the statistics; a mismatch shows
/// what was keyed, discards that attempt's timings, and waits for the same
/// letter again — so one slip never poisons the rest of the line. If the
/// commit matches the letter AFTER the expected one instead, the expected
/// letter is treated as skipped and measurement resyncs there.
///
/// * Straight key: dit and dah press lengths plus letter and word gaps are
///   scored (the operator makes all the timing).
/// * Iambic: the machine makes the element timing, so only the letter and
///   word gaps are scored.
///
/// On completion the screen shows a histogram per category, a consistency
/// score (100% minus the coefficient of variation — 100% means every
/// duration in the category was identical), and the actual sending speed:
/// the line's nominal PARIS units divided by the elapsed time, as WPM.
class TimingScreen extends StatefulWidget {
  const TimingScreen({super.key});

  @override
  State<TimingScreen> createState() => _TimingScreenState();
}

enum _Phase { keying, results }

class _TimingScreenState extends State<TimingScreen> {
  final _random = Random();
  final _focusNode = FocusNode(debugLabel: 'TimingInput');

  Settings? _settings;
  late IambicKeyer _keyer;
  CombinedPaddleSource? _paddles;

  _Phase _phase = _Phase.keying;
  KeyerMode _modeAtStart = KeyerMode.iambic;

  // The target line and its expected characters.
  String _line = '';
  final List<({String pattern, bool wordBefore})> _expChars = [];
  final List<String> _charMorse = []; // display morse per char ('' = space)
  int _lineUnits = 0; // nominal PARIS units of the whole line
  int _charIdx = 0; // accepted characters

  // Measurement buckets (accepted samples only).
  final List<double> _dits = [];
  final List<double> _dahs = [];
  final List<double> _letterGaps = [];
  final List<double> _wordGaps = [];

  // Per-character buffers, accepted or discarded at each keyer commit.
  final List<double> _pressBuf = []; // straight: press durations, in order
  double? _pendingBoundary; // gap before this character, ms
  bool _boundaryValid = false; // false right after a rejected attempt

  final Stopwatch _clock = Stopwatch()..start();
  int? _tFirst; // first press / element start of the line
  int? _lastEnd; // end of the last ACCEPTED character's final element
  int _lastUp = 0; // straight: most recent release
  int _curEnd = 0; // iambic: end of the most recent element
  int _elemCount = 0; // iambic: elements since the last commit
  String? _errorDecoded; // what a rejected attempt decoded to
  int _wpm = 0;

  // Straight-key raw contact tracking.
  bool _ditContact = false;
  bool _dahContact = false;
  bool _contact = false;
  int _tDown = 0;

  bool get _straight => _modeAtStart == KeyerMode.straight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settings == null) {
      final scope = AppScope.of(context);
      _settings = scope.settings;
      _keyer = IambicKeyer(
        ditMs: () => _settings!.ditMs,
        straightKey: () => _settings!.keyerMode == KeyerMode.straight,
        audio: scope.audio,
        onElement: _onElement,
        onCharacter: _onCharacter,
      );
      _keyer.start();
      _settings!.addListener(_onSettingsChanged);
      _attachPaddles(scope.paddles);
      _newLine();
    }
  }

  @override
  void dispose() {
    _detachPaddles();
    _settings?.removeListener(_onSettingsChanged);
    _keyer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    if (!mounted) return;
    // Switching keyer mode invalidates any in-progress measurements, and on
    // the results view it signals intent to key a fresh line in that mode.
    if (_settings!.keyerMode != _modeAtStart) {
      _newLine();
    } else {
      setState(() {});
    }
  }

  // --- Shared paddle source ---------------------------------------------------

  void _handleDit(bool down) {
    _onContact(dit: down);
    _keyer.setDit(down);
  }

  void _handleDah(bool down) {
    _onContact(dah: down);
    _keyer.setDah(down);
  }

  void _handleStatus() {
    if (mounted) setState(() {});
  }

  /// Attaches this screen's keyer to the app-wide shared paddle source.
  void _attachPaddles(CombinedPaddleSource paddles) {
    _paddles = paddles;
    paddles.onDit = _handleDit;
    paddles.onDah = _handleDah;
    paddles.onStatus = _handleStatus;
  }

  /// Detaches, but only if the callbacks are still ours: the next keying
  /// screen attaches BEFORE this one's dispose runs, and must not be
  /// clobbered. (Same-instance method tear-offs compare equal.)
  void _detachPaddles() {
    final p = _paddles;
    if (p == null) return;
    if (p.onDit == _handleDit) p.onDit = null;
    if (p.onDah == _handleDah) p.onDah = null;
    if (p.onStatus == _handleStatus) p.onStatus = null;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final handled = _paddles?.handleKeyEvent(event) ?? false;
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  void _refocus() {
    if (mounted) _focusNode.requestFocus();
  }

  // --- Line setup -------------------------------------------------------------

  void _newLine() {
    setState(() {
      _phase = _Phase.keying;
      _modeAtStart = _settings!.keyerMode;
      _line = kSampleLines[_random.nextInt(kSampleLines.length)];
      _expChars.clear();
      _charMorse.clear();
      _dits.clear();
      _dahs.clear();
      _letterGaps.clear();
      _wordGaps.clear();
      _pressBuf.clear();
      _pendingBoundary = null;
      _boundaryValid = true;
      _charIdx = 0;
      _tFirst = null;
      _lastEnd = null;
      _elemCount = 0;
      _errorDecoded = null;
      _wpm = 0;
      _ditContact = _dahContact = _contact = false;

      _lineUnits = 0;
      var pendingWord = false;
      for (final ch in _line.toUpperCase().split('')) {
        if (ch == ' ') {
          pendingWord = true;
          _charMorse.add('');
          continue;
        }
        final pattern = morseForChar(ch);
        if (pattern == null) {
          _charMorse.add('');
          continue;
        }
        if (_expChars.isNotEmpty) {
          _lineUnits += pendingWord ? 7 : 3;
        }
        for (var j = 0; j < pattern.length; j++) {
          if (j > 0) _lineUnits += 1; // intra-character gap
          _lineUnits += pattern[j] == '-' ? 3 : 1;
        }
        _expChars.add((pattern: pattern, wordBefore: pendingWord));
        _charMorse.add(displayMorse(pattern));
        pendingWord = false;
      }
    });
    _keyer.clear();
    _refocus();
  }

  // --- Measurement ------------------------------------------------------------

  /// Straight mode: raw contact transitions carry the press/gap timing.
  void _onContact({bool? dit, bool? dah}) {
    if (!_straight || _phase != _Phase.keying) return;
    if (dit != null) _ditContact = dit;
    if (dah != null) _dahContact = dah;
    final down = _ditContact || _dahContact;
    if (down == _contact) return;
    _contact = down;
    final now = _clock.elapsedMilliseconds;
    if (down) {
      _tFirst ??= now;
      if (_pressBuf.isEmpty && _boundaryValid && _lastEnd != null) {
        _pendingBoundary = (now - _lastEnd!).toDouble();
      }
      _tDown = now;
    } else {
      _lastUp = now;
      _pressBuf.add((now - _tDown).toDouble());
    }
  }

  /// Iambic mode: the keyer reports each machine-timed element start; only
  /// the pause before a character's first element is the operator's timing.
  void _onElement(String element) {
    if (_straight || _phase != _Phase.keying) return;
    final now = _clock.elapsedMilliseconds;
    _tFirst ??= now;
    if (_elemCount == 0 && _boundaryValid && _lastEnd != null) {
      _pendingBoundary = (now - _lastEnd!).toDouble();
    }
    _elemCount++;
    _curEnd = now + (element == '-' ? 3 : 1) * _settings!.ditMs;
  }

  /// The keyer committed a pattern: align it against the expected letters.
  void _onCharacter(String pattern, String? char) {
    if (_phase != _Phase.keying || _charIdx >= _expChars.length) {
      _clearCharBuffers();
      return;
    }
    if (pattern == _expChars[_charIdx].pattern) {
      _accept(pattern, at: _charIdx);
    } else if (_charIdx + 1 < _expChars.length &&
        pattern == _expChars[_charIdx + 1].pattern) {
      // The expected letter was skipped; resync one ahead. The boundary gap
      // spans the skipped letter, so it is not scored.
      _pendingBoundary = null;
      _accept(pattern, at: _charIdx + 1);
    } else {
      // Mismatch: discard this attempt's timings and wait for a re-key.
      setState(() => _errorDecoded = char ?? displayMorse(pattern));
      _boundaryValid = false;
      _clearCharBuffers();
    }
  }

  void _accept(String pattern, {required int at}) {
    setState(() {
      if (_straight) {
        final n = min(pattern.length, _pressBuf.length);
        for (var j = 0; j < n; j++) {
          (pattern[j] == '-' ? _dahs : _dits).add(_pressBuf[j]);
        }
      }
      final boundary = _pendingBoundary;
      if (boundary != null && at > 0) {
        (_expChars[at].wordBefore ? _wordGaps : _letterGaps).add(boundary);
      }
      _errorDecoded = null;
      _charIdx = at + 1;
    });
    _lastEnd = _straight ? _lastUp : _curEnd;
    _boundaryValid = true;
    _clearCharBuffers();
    if (_charIdx >= _expChars.length) _complete();
  }

  void _clearCharBuffers() {
    _pressBuf.clear();
    _pendingBoundary = null;
    if (!_straight) _elemCount = 0;
  }

  void _complete() {
    final first = _tFirst;
    final last = _lastEnd;
    if (first != null && last != null && last > first && _lineUnits > 0) {
      _wpm = (1200 * _lineUnits / (last - first)).round();
    }
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && _phase == _Phase.keying) {
        setState(() => _phase = _Phase.results);
      }
    });
  }

  // --- Statistics -------------------------------------------------------------

  ({double mean, double sd, int consistency})? _stats(List<double> xs) {
    if (xs.isEmpty) return null;
    final mean = xs.reduce((a, b) => a + b) / xs.length;
    final variance =
        xs.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
            xs.length;
    final sd = sqrt(variance);
    final consistency =
        mean <= 0 ? 0 : (100 - (sd / mean) * 100).round().clamp(0, 100);
    return (mean: mean, sd: sd, consistency: consistency);
  }

  // --- UI ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final usb = _paddles?.usbConnected == true;

    return PageScaffold(
      title: l10n.menuTiming,
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _refocus,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Controls fold onto extra rows on narrow screens.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _newLine,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.timingRestart),
                  ),
                  // Quick keyer-mode switch; writes the shared setting, so
                  // it stays in sync with the Settings screen and restarts
                  // the line in the chosen mode.
                  SegmentedButton<KeyerMode>(
                    segments: [
                      ButtonSegment(
                        value: KeyerMode.iambic,
                        label: Text(l10n.keyerModeIambic),
                      ),
                      ButtonSegment(
                        value: KeyerMode.straight,
                        label: Text(l10n.keyerModeStraight),
                      ),
                    ],
                    selected: {_settings!.keyerMode},
                    onSelectionChanged: (selection) =>
                        _settings!.keyerMode = selection.first,
                    showSelectedIcon: false,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    usb ? Icons.usb : Icons.keyboard,
                    size: 18,
                    color: usb ? Colors.green : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _paddles?.statusText(l10n) ?? l10n.statusStarting,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _phase == _Phase.keying
                    ? _keyingView(theme, l10n)
                    : _resultsView(theme, l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keyingView(ThemeData theme, AppLocalizations l10n) {
    // Three-tone rendering of the text and its morse: accepted characters in
    // primary, the character expected NOW under a highlight cursor, the rest
    // muted. Text characters and morse pieces are index-aligned, so one
    // pass builds both span lists.
    final highlight = TextStyle(
      color: theme.colorScheme.onPrimaryContainer,
      backgroundColor: theme.colorScheme.primaryContainer,
      fontWeight: FontWeight.bold,
    );
    final donePrimary = TextStyle(color: theme.colorScheme.primary);
    final restMuted = TextStyle(color: theme.colorScheme.onSurfaceVariant);

    final textSpans = <TextSpan>[];
    final morseSpans = <TextSpan>[];
    var keyableSeen = 0;
    for (var i = 0; i < _charMorse.length; i++) {
      final piece = _charMorse[i];
      final keyable = piece.isNotEmpty;
      if (keyable) keyableSeen++;
      final isDone = keyableSeen <= _charIdx;
      final isCurrent = keyable && keyableSeen == _charIdx + 1;
      final trail = isDone ? donePrimary : restMuted;

      textSpans.add(TextSpan(
        text: _line[i],
        style: isCurrent ? highlight : (isDone ? donePrimary : null),
      ));
      if (keyable) {
        morseSpans.add(TextSpan(
          text: piece,
          style: isCurrent ? highlight : trail,
        ));
        morseSpans.add(TextSpan(text: '  ', style: trail));
      } else {
        morseSpans.add(TextSpan(text: '/  ', style: trail));
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _straight ? l10n.timingInstruction : l10n.timingIambicNote,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: theme.textTheme.headlineSmall,
              children: textSpans,
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: theme.textTheme.titleLarge?.copyWith(
                letterSpacing: 3,
                height: 1.8,
              ),
              children: morseSpans,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 24,
            child: _errorDecoded == null
                ? null
                : Text(
                    l10n.youKeyedTryAgain(_errorDecoded!),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _expChars.isEmpty ? 0 : _charIdx / _expChars.length,
          ),
        ],
      ),
    );
  }

  Widget _resultsView(ThemeData theme, AppLocalizations l10n) {
    final rows = <({String label, List<double> xs})>[
      if (_straight) (label: l10n.timingDits, xs: _dits),
      if (_straight) (label: l10n.timingDahs, xs: _dahs),
      (label: l10n.timingLetterGaps, xs: _letterGaps),
      (label: l10n.timingWordGaps, xs: _wordGaps),
    ];
    final consistencies = <int>[];
    for (final r in rows) {
      final s = _stats(r.xs);
      if (s != null) consistencies.add(s.consistency);
    }
    final overall = consistencies.isEmpty
        ? 0
        : (consistencies.reduce((a, b) => a + b) / consistencies.length)
            .round();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.timingComplete, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                l10n.timingOverall(overall),
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 24),
              Text(
                l10n.timingWpm(_wpm),
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.tertiary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final r in rows) _categoryCard(theme, l10n, r.label, r.xs),
        ],
      ),
    );
  }

  Widget _categoryCard(ThemeData theme, AppLocalizations l10n, String label,
      List<double> xs) {
    final s = _stats(xs);
    if (s == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                l10n.timingConsistency(s.consistency),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: s.consistency >= 80
                      ? Colors.green
                      : (s.consistency >= 50
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.timingStats(s.mean.round(), s.sd.round(), xs.length),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 8),
          _Histogram(samples: xs, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}

/// A minimal bar-chart of sample durations: fixed bin count over the sample
/// range, tallest bin normalised to full height.
class _Histogram extends StatelessWidget {
  const _Histogram({required this.samples, required this.color});

  final List<double> samples;
  final Color color;

  static const int _bins = 16;
  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lo = samples.reduce(min);
    final hi = samples.reduce(max);
    final span = max(hi - lo, 1.0);
    final counts = List<int>.filled(_bins, 0);
    for (final x in samples) {
      final bin = min(((x - lo) / span * _bins).floor(), _bins - 1);
      counts[bin]++;
    }
    final peak = counts.reduce(max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final c in counts)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: peak == 0 ? 0 : _height * c / peak,
                    decoration: BoxDecoration(
                      color: c == 0 ? Colors.transparent : color,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${lo.round()} ms', style: theme.textTheme.labelSmall),
            Text('${hi.round()} ms', style: theme.textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}
