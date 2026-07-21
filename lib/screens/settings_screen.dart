import 'dart:io';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../input/hid_paddle_source.dart';
import '../l10n/enum_l10n.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/settings.dart';
import '../morsey/morse_code.dart';
import 'page_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _usbPath;

  @override
  void initState() {
    super.initState();
    _detectUsb();
  }

  Future<void> _detectUsb() async {
    final path = await HidPaddleSource.detect();
    if (!mounted) return;
    setState(() => _usbPath = path);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final settings = scope.settings;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return PageScaffold(
      title: l10n.menuSettings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return ListView(
            children: [
              _sectionTitle(context, l10n.settingsInputDevice),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(
                  l10n.settingsInputDeviceBody,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              // USB status. On touch platforms the key is read as a hardware
              // keyboard, so there is nothing to detect.
              if (Platform.isIOS || Platform.isAndroid)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.usb,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.settingsUsbActsAsKeyboard,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else if (Platform.isLinux || Platform.isMacOS)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        _usbPath != null ? Icons.usb : Icons.usb_off,
                        color: _usbPath != null
                            ? Colors.green
                            : theme.colorScheme.outline,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _usbPath != null
                              ? l10n.settingsUsbDetected(_usbPath!)
                              : l10n.settingsUsbNotDetected,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _detectUsb,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(l10n.settingsRescan),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),
              _sectionTitle(context, l10n.settingsPaddleOrientation),
              RadioGroup<DitPaddle>(
                groupValue: settings.ditPaddle,
                onChanged: (v) => settings.ditPaddle = v!,
                child: Column(
                  children: DitPaddle.values
                      .map(
                        (p) => RadioListTile<DitPaddle>(
                          value: p,
                          title: Text(p.label(l10n)),
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),
              _sectionTitle(context, l10n.settingsSpeed),
              _sliderRow(
                context,
                label: l10n.settingsKeyingSpeed,
                valueLabel: l10n.settingsWpmValue(
                    settings.wpm, settings.ditMs),
                value: settings.wpm.toDouble(),
                min: 5,
                max: 40,
                divisions: 35,
                onChanged: (v) => settings.wpm = v.round(),
              ),

              const SizedBox(height: 16),
              _sectionTitle(context, l10n.settingsSideTone),
              _sliderRow(
                context,
                label: l10n.settingsVolume,
                valueLabel: l10n.settingsVolumeValue(
                    (settings.volume * 100).round()),
                value: settings.volume,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: (v) => settings.volume = v,
              ),
              _sliderRow(
                context,
                label: l10n.settingsFrequency,
                valueLabel: l10n.settingsFrequencyValue(
                    settings.frequency.round()),
                value: settings.frequency,
                min: 200,
                max: 1200,
                divisions: 50,
                onChanged: (v) => settings.frequency = v,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        scope.audio.toneOn();
                        await Future<void>.delayed(
                            const Duration(milliseconds: 400));
                        scope.audio.toneOff();
                      },
                      icon: const Icon(Icons.volume_up),
                      label: Text(l10n.settingsTestTone),
                    ),
                    const SizedBox(width: 12),
                    if (!scope.audio.available)
                      Text(
                        l10n.settingsNoAudio,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _sectionTitle(context, l10n.settingsCharacterSet),
              RadioGroup<CharacterSet>(
                groupValue: settings.characterSet,
                onChanged: (v) => settings.characterSet = v!,
                child: Column(
                  children: CharacterSet.values
                      .map(
                        (c) => RadioListTile<CharacterSet>(
                          value: c,
                          title: Text(c.label(l10n)),
                          subtitle: Text(c.description(l10n)),
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),
              _sectionTitle(context, l10n.settingsAppearance),
              RadioGroup<AppTheme>(
                groupValue: settings.appTheme,
                onChanged: (v) => settings.appTheme = v!,
                child: Column(
                  children: AppTheme.values
                      .map(
                        (t) => RadioListTile<AppTheme>(
                          value: t,
                          title: Text(t.label(l10n)),
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),
              _sectionTitle(context, l10n.settingsLanguage),
              RadioGroup<AppLanguage>(
                groupValue: settings.language,
                onChanged: (v) => settings.language = v!,
                child: Column(
                  children: AppLanguage.values
                      .map(
                        (lang) => RadioListTile<AppLanguage>(
                          value: lang,
                          title: Text(lang.label(l10n)),
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      );

  Widget _sliderRow(
    BuildContext context, {
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(valueLabel,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
