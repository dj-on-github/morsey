import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'audio/audio_engine.dart';
import 'models/settings.dart';
import 'screens/about_screen.dart';
import 'screens/input_train_screen.dart';
import 'screens/input_tutorial_screen.dart';
import 'screens/listen_train_screen.dart';
import 'screens/listen_tutorial_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = Settings();
  final audio = createAudioEngine(
    frequency: settings.frequency,
    volume: settings.volume,
  );
  await audio.start();

  // Keep the audio engine's live parameters in sync with settings.
  settings.addListener(() {
    audio.frequency = settings.frequency;
    audio.volume = settings.volume;
  });

  runApp(MorseyApp(settings: settings, audio: audio));
}

class MorseyApp extends StatelessWidget {
  const MorseyApp({super.key, required this.settings, required this.audio});

  final Settings settings;
  final AudioEngine audio;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      settings: settings,
      audio: audio,
      child: MaterialApp(
        title: 'Morse Trainer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.dark,
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}

/// A selectable part of the program shown in the left column.
class _Section {
  const _Section(this.title, this.icon, this.builder);
  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selected = 2; // start on Input Train

  static final List<_Section> _sections = [
    _Section('About', Icons.info_outline, (_) => const AboutScreen()),
    _Section('Settings', Icons.settings, (_) => const SettingsScreen()),
    _Section('Input Train', Icons.keyboard, (_) => const InputTrainScreen()),
    _Section('Listen Train', Icons.hearing, (_) => const ListenTrainScreen()),
    _Section('Listen Tutorial', Icons.school,
        (_) => const ListenTutorialScreen()),
    _Section('Input Tutorial', Icons.school_outlined,
        (_) => const InputTutorialScreen()),
  ];

  /// Width below which the sidebar collapses into a drawer.
  static const double _compactBreakpoint = 720;

  /// Builds the navigation menu shared by the permanent sidebar and the drawer.
  ///
  /// When [inDrawer] is true, tapping an item also closes the drawer.
  Widget _buildMenu(BuildContext context, {required bool inDrawer}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Icon(Icons.graphic_eq, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Morse Trainer',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _sections.length,
            itemBuilder: (context, i) {
              final section = _sections[i];
              final selected = i == _selected;
              return ListTile(
                leading: Icon(section.icon),
                title: Text(section.title),
                selected: selected,
                selectedTileColor:
                    theme.colorScheme.primary.withValues(alpha: 0.18),
                onTap: () {
                  setState(() => _selected = i);
                  if (inDrawer) Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < _compactBreakpoint;

        if (isCompact) {
          // Narrow / mobile layout: sidebar hidden behind a hamburger menu.
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              title: Row(
                children: [
                  Icon(Icons.graphic_eq, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      _sections[_selected].title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            drawer: Drawer(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: SafeArea(child: _buildMenu(context, inDrawer: true)),
            ),
            body: _sections[_selected].builder(context),
          );
        }

        // Wide layout: permanent sidebar alongside the content.
        return Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left column: list of program parts.
              Material(
                color: theme.colorScheme.surfaceContainerHighest,
                child: SizedBox(
                  width: 220,
                  child: _buildMenu(context, inDrawer: false),
                ),
              ),
              const VerticalDivider(width: 1),
              // Right pane: the selected part.
              Expanded(
                child: _sections[_selected].builder(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
