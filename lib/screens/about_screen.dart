import 'package:flutter/material.dart';

import 'page_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PageScaffold(
      title: 'About',
      child: ListView(
        children: [
          Text(
            'A practice tool for learning Morse code, written in Dart / Flutter.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _Heading('The parts of the program'),
          const _Bullet('About',
              'This page — a description of the program and how it works.'),
          const _Bullet('Settings',
              'Choose the input device (USB paddle or keyboard), set the '
                  'keying speed, and the side-tone volume and frequency.'),
          const _Bullet('Input Train',
              'A character is shown and you key it in Morse. The trainer '
                  'decodes what you send and tells you if it was correct.'),
          const _Bullet('Listen Train',
              'The trainer plays a character in Morse audio and you type the '
                  'character you heard.'),
          const _Bullet('Listen Tutorial',
              'A guided, 26-level listening course. Each level introduces one '
                  'new letter (Koch-method order — the easiest-to-distinguish '
                  'sounds come first): the letter is shown and its Morse is '
                  'played, you type it to begin, then a random drill of every '
                  'letter unlocked so far runs until each has been answered '
                  'correctly three times. Completing a level unlocks the next, '
                  'and your progress is remembered.'),
          const _Bullet('Input Tutorial',
              'The same 26-level course with the roles reversed, to teach '
                  'sending. Each level shows the new letter\'s dots and dashes '
                  'with the letter beside them; key the pattern to begin. In '
                  'practice the pattern is taken away — only the letter is '
                  'shown — and you key its Morse from memory with the paddle '
                  'or keyboard, watching a live display of what you are '
                  'keying. A "Hear it" button plays the target\'s rhythm, and '
                  'a hint can reveal the pattern if you get stuck. Progress '
                  'is tracked separately from the Listen Tutorial.'),
          const SizedBox(height: 24),
          _Heading('The USB Morse key'),
          Text(
            'This program supports an iambic (dual-paddle) Morse key that '
            'enumerates over USB as device 413d:2107. On Linux the key is read '
            'directly from its /dev/hidraw node — no drivers required, as long '
            'as your user can read the device (the plugdev group / a udev '
            'rule). Each paddle is reported as a keyboard modifier bit '
            '(Left-Ctrl and Right-Ctrl); the software turns those paddle '
            'presses into properly-timed dits and dahs.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _Heading('Timing'),
          Text(
            'Speed is expressed in words per minute (WPM) using standard PARIS '
            'timing: one dit = 1200 / WPM milliseconds, a dah is three dits, '
            'the gap between elements is one dit, and the gap between letters '
            'is three dits.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            'Version 1.0.0',
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

