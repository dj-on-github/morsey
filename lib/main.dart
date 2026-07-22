import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'audio/audio_engine.dart';
import 'input/combined_paddle_source.dart';
import 'l10n/fallback_localizations.dart';
import 'l10n/gen/app_localizations.dart';
import 'models/settings.dart';
import 'screens/about_screen.dart';
import 'screens/free_key_screen.dart';
import 'screens/free_type_screen.dart';
import 'screens/input_train_screen.dart';
import 'screens/input_tutorial_screen.dart';
import 'screens/listen_train_screen.dart';
import 'screens/listen_tutorial_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await Settings.load();
  final audio = createAudioEngine(
    frequency: settings.frequency,
    volume: settings.volume,
  );
  await audio.start();

  // One app-lifetime paddle source shared by every keying screen. Screens
  // must NOT open/close their own: on macOS they all share one native
  // IOHIDManager, and a new screen's start raced the old screen's dispose
  // (dispose runs after the next screen builds), killing USB input on every
  // keying-screen to keying-screen switch.
  final paddles = CombinedPaddleSource(
    ditIsLeft: settings.ditPaddle == DitPaddle.left,
  );
  await paddles.start();

  // Keep the audio engine's and paddle source's live parameters in sync.
  settings.addListener(() {
    audio.frequency = settings.frequency;
    audio.volume = settings.volume;
    paddles.ditIsLeft = settings.ditPaddle == DitPaddle.left;
  });

  runApp(MorseyApp(settings: settings, audio: audio, paddles: paddles));
}

class MorseyApp extends StatelessWidget {
  const MorseyApp({
    super.key,
    required this.settings,
    required this.audio,
    required this.paddles,
  });

  final Settings settings;
  final AudioEngine audio;
  final CombinedPaddleSource paddles;

  static ThemeData _theme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: brightness,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppScope(
      settings: settings,
      audio: audio,
      paddles: paddles,
      // Rebuild on settings changes so the theme choice applies immediately.
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) =>
              AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          locale: settings.language.locale,
          supportedLocales: const [
            Locale('en'), // first = fallback for unsupported system locales
            Locale('cy'),
            Locale('de'),
            Locale('es'),
            Locale('fr'),
            Locale('hi'),
            Locale('ja'),
            Locale('tlh'),
            Locale('zh'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            // After the global ones: real framework translations win when
            // Flutter has them; otherwise English framework strings.
            FallbackMaterialLocalizationsDelegate(),
            FallbackWidgetsLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
          ],
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: switch (settings.appTheme) {
            AppTheme.system => ThemeMode.system,
            AppTheme.light => ThemeMode.light,
            AppTheme.dark => ThemeMode.dark,
          },
          home: const HomePage(),
        ),
      ),
    );
  }
}

/// A selectable part of the program shown in the left column. The title is
/// resolved per-build so it follows the active locale.
class _Section {
  const _Section(this.title, this.icon, this.builder);
  final String Function(AppLocalizations l10n) title;
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
    _Section((l) => l.menuAbout, Icons.info_outline,
        (_) => const AboutScreen()),
    _Section((l) => l.menuSettings, Icons.settings,
        (_) => const SettingsScreen()),
    _Section((l) => l.menuInputTrain, Icons.keyboard,
        (_) => const InputTrainScreen()),
    _Section((l) => l.menuListenTrain, Icons.hearing,
        (_) => const ListenTrainScreen()),
    _Section((l) => l.menuListenTutorial, Icons.school,
        (_) => const ListenTutorialScreen()),
    _Section((l) => l.menuInputTutorial, Icons.school_outlined,
        (_) => const InputTutorialScreen()),
    _Section((l) => l.menuFreeType, Icons.edit_note,
        (_) => const FreeTypeScreen()),
    _Section((l) => l.menuFreeKey, Icons.cell_tower,
        (_) => const FreeKeyScreen()),
  ];

  /// Width below which the sidebar collapses into a drawer.
  static const double _compactBreakpoint = 720;

  /// Builds the navigation menu shared by the permanent sidebar and the drawer.
  ///
  /// When [inDrawer] is true, tapping an item also closes the drawer.
  Widget _buildMenu(BuildContext context, {required bool inDrawer}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
                  l10n.appTitle,
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
                title: Text(section.title(l10n)),
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
                      _sections[_selected].title(AppLocalizations.of(context)),
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
