import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../input/hid_paddle_source.dart';
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

  void _detectUsb() {
    setState(() => _usbPath = HidPaddleSource.findDevicePath());
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final settings = scope.settings;
    final theme = Theme.of(context);

    return PageScaffold(
      title: 'Settings',
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return ListView(
            children: [
              _sectionTitle(context, 'Input device'),
              RadioGroup<InputMethod>(
                groupValue: settings.inputMethod,
                onChanged: (v) => settings.inputMethod = v!,
                child: Column(
                  children: InputMethod.values
                      .map(
                        (m) => RadioListTile<InputMethod>(
                          value: m,
                          title: Text(m.label),
                          subtitle: Text(m.description),
                        ),
                      )
                      .toList(),
                ),
              ),
              // USB detection status.
              if (settings.inputMethod == InputMethod.usbPaddle)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        _usbPath != null ? Icons.usb : Icons.usb_off,
                        color: _usbPath != null
                            ? Colors.green
                            : theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _usbPath != null
                              ? 'USB key 413d:2107 detected at $_usbPath'
                              : 'USB key 413d:2107 not found — plug it in, or '
                                  'check that you can read /dev/hidraw*',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _detectUsb,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Re-scan'),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),
              _sectionTitle(context, 'Paddle orientation'),
              RadioGroup<DitPaddle>(
                groupValue: settings.ditPaddle,
                onChanged: (v) => settings.ditPaddle = v!,
                child: Column(
                  children: DitPaddle.values
                      .map(
                        (p) => RadioListTile<DitPaddle>(
                          value: p,
                          title: Text(p.label),
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),
              _sectionTitle(context, 'Speed'),
              _sliderRow(
                context,
                label: 'Keying speed',
                valueLabel: '${settings.wpm} WPM  '
                    '(dit = ${settings.ditMs} ms)',
                value: settings.wpm.toDouble(),
                min: 5,
                max: 40,
                divisions: 35,
                onChanged: (v) => settings.wpm = v.round(),
              ),

              const SizedBox(height: 16),
              _sectionTitle(context, 'Side-tone'),
              _sliderRow(
                context,
                label: 'Volume',
                valueLabel: '${(settings.volume * 100).round()} %',
                value: settings.volume,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: (v) => settings.volume = v,
              ),
              _sliderRow(
                context,
                label: 'Frequency',
                valueLabel: '${settings.frequency.round()} Hz',
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
                      label: const Text('Test tone'),
                    ),
                    const SizedBox(width: 12),
                    if (!scope.audio.available)
                      Text(
                        'No audio backend available (needs pacat / PulseAudio).',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _sectionTitle(context, 'Training character set'),
              RadioGroup<CharacterSet>(
                groupValue: settings.characterSet,
                onChanged: (v) => settings.characterSet = v!,
                child: Column(
                  children: CharacterSet.values
                      .map(
                        (c) => RadioListTile<CharacterSet>(
                          value: c,
                          title: Text(c.label),
                          subtitle: Text(c.description),
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
