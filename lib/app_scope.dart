import 'package:flutter/widgets.dart';

import 'audio/audio_engine.dart';
import 'models/settings.dart';

/// Makes the shared [Settings] and [AudioEngine] available to the widget tree.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.settings,
    required this.audio,
    required super.child,
  });

  final Settings settings;
  final AudioEngine audio;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      settings != oldWidget.settings || audio != oldWidget.audio;
}
