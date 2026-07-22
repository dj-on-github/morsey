import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import 'page_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return PageScaffold(
      title: l10n.menuAbout,
      child: ListView(
        children: [
          Text(
            l10n.aboutIntro,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _Heading(l10n.aboutPartsHeading),
          _Bullet(l10n.menuAbout, l10n.aboutAboutDesc),
          _Bullet(l10n.menuSettings, l10n.aboutSettingsDesc),
          _Bullet(l10n.menuInputTrain, l10n.aboutInputTrainDesc),
          _Bullet(l10n.menuListenTrain, l10n.aboutListenTrainDesc),
          _Bullet(l10n.menuListenTutorial, l10n.aboutListenTutorialDesc),
          _Bullet(l10n.menuInputTutorial, l10n.aboutInputTutorialDesc),
          _Bullet(l10n.menuFreeType, l10n.aboutFreeTypeDesc),
          _Bullet(l10n.menuFreeKey, l10n.aboutFreeKeyDesc),
          _Bullet(l10n.menuTiming, l10n.aboutTimingScreenDesc),
          const SizedBox(height: 24),
          _Heading(l10n.aboutUsbHeading),
          Text(
            l10n.aboutUsbBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _Heading(l10n.aboutTimingHeading),
          Text(
            l10n.aboutTimingBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.aboutVersion('1.0.0'),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.term, this.text);
  final String term;
  final String text;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                      text: '$term — ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
