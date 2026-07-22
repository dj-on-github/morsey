import 'package:flutter_test/flutter_test.dart';

import 'package:morsey/audio/audio_engine.dart';
import 'package:morsey/input/combined_paddle_source.dart';
import 'package:morsey/models/settings.dart';
import 'package:morsey/morsey/morse_code.dart';
import 'package:morsey/main.dart';

void main() {
  group('Morse code table', () {
    test('encodes and decodes are inverse', () {
      for (final entry in kCharToMorse.entries) {
        expect(charForMorse(entry.value), entry.key);
        expect(morseForChar(entry.key), entry.value);
      }
    });

    test('well-known characters', () {
      expect(morseForChar('S'), '...');
      expect(morseForChar('O'), '---');
      expect(charForMorse('.-'), 'A');
    });

    test('character sets are non-empty and disjoint where expected', () {
      expect(CharacterSet.letters.characters.length, 26);
      expect(CharacterSet.numbers.characters.length, 10);
      expect(
        CharacterSet.lettersAndNumbers.characters.length,
        36,
      );
    });
  });

  group('Settings', () {
    test('dit length follows PARIS timing', () {
      final s = Settings()..wpm = 20;
      expect(s.ditMs, 60); // 1200 / 20
      s.wpm = 12;
      expect(s.ditMs, 100);
    });

    test('values are clamped', () {
      final s = Settings()
        ..wpm = 999
        ..volume = 2
        ..frequency = 50;
      expect(s.wpm, 40);
      expect(s.volume, 1.0);
      expect(s.frequency, 200);
    });
  });

  testWidgets('App shows the program parts', (tester) async {
    await tester.pumpWidget(
      MorseyApp(
        settings: Settings(),
        audio: SilentAudioEngine(),
        paddles: CombinedPaddleSource(),
      ),
    );
    await tester.pump();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Input Train'), findsWidgets);
    expect(find.text('Listen Train'), findsOneWidget);
    expect(find.text('Listen Tutorial'), findsOneWidget);
    expect(find.text('Input Tutorial'), findsOneWidget);

    // Navigate to About.
    await tester.tap(find.text('About'));
    await tester.pump();
    expect(find.textContaining('practice tool'), findsWidgets);
  });
}
