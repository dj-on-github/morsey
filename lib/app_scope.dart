import 'package:flutter/widgets.dart';

import 'audio/audio_engine.dart';
import 'input/combined_paddle_source.dart';
import 'models/settings.dart';

/// Makes the shared [Settings], [AudioEngine] and paddle source available to
/// the widget tree.
///
/// The paddle source is app-lifetime and shared: there is one physical
/// device, and per-screen open/close raced on the single native IOHIDManager
/// when switching between keying screens (the new screen's start was torn
/// down by the old screen's dispose). Screens attach their callbacks instead
/// of creating sources.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.settings,
    required this.audio,
    required this.paddles,
    required super.child,
  });

  final Settings settings;
  final AudioEngine audio;
  final CombinedPaddleSource paddles;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      settings != oldWidget.settings ||
      audio != oldWidget.audio ||
      paddles != oldWidget.paddles;
}
