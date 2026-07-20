import 'package:flutter_test/flutter_test.dart';
import 'package:morsey/audio/audio_engine.dart';
import 'package:morsey/morse/iambic_keyer.dart';

/// Drives an [IambicKeyer] with a simulated paddle and checks that it decodes
/// the expected characters. Uses real timers with generous timing so the test
/// is not brittle; dit length is 60 ms.
void main() {
  const dit = 60;

  Future<void> wait(int ms) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  late IambicKeyer keyer;
  late List<String> decoded;

  setUp(() {
    decoded = [];
    keyer = IambicKeyer(
      ditMs: () => dit,
      audio: SilentAudioEngine(),
      onCharacter: (pattern, ch) => decoded.add(ch ?? '?'),
    );
    keyer.start();
  });

  tearDown(() => keyer.dispose());

  test('a single short dit decodes to E', () async {
    keyer.setDit(true);
    await wait(20); // released well before the element ends
    keyer.setDit(false);
    await wait(dit * 5); // let the letter gap commit
    expect(decoded, ['E']);
  });

  test('a single dah decodes to T', () async {
    keyer.setDah(true);
    await wait(20);
    keyer.setDah(false);
    await wait(dit * 6);
    expect(decoded, ['T']);
  });

  test('dit then dah (squeeze) decodes to A', () async {
    keyer.setDit(true);
    await wait(20);
    keyer.setDit(false);
    // Pulse the dah paddle during the dit so iambic memory queues a dah.
    await wait(10);
    keyer.setDah(true);
    await wait(20);
    keyer.setDah(false);
    await wait(dit * 8);
    expect(decoded, ['A']);
  }, timeout: const Timeout(Duration(seconds: 5)));

  test('holding the dit paddle sends a stream of dits', () async {
    keyer.setDit(true);
    // Hold long enough for ~3 dit+gap cycles (each is 2*dit).
    await wait(dit * 5);
    keyer.setDit(false);
    await wait(dit * 5);
    // Should have decoded one character made of several dits (S/H/5...),
    // i.e. exactly one committed character consisting only of dits.
    expect(decoded.length, 1);
    expect('EISH5'.contains(decoded.first), isTrue,
        reason: 'expected an all-dits character, got ${decoded.first}');
  }, timeout: const Timeout(Duration(seconds: 5)));
}
