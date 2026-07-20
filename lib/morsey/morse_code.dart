/// Morse code alphabet and helpers.
///
/// A Morse pattern is represented as a String of '.' (dit) and '-' (dah).
library;

/// Maps a character to its Morse pattern (dits and dahs).
const Map<String, String> kCharToMorse = {
  'A': '.-',
  'B': '-...',
  'C': '-.-.',
  'D': '-..',
  'E': '.',
  'F': '..-.',
  'G': '--.',
  'H': '....',
  'I': '..',
  'J': '.---',
  'K': '-.-',
  'L': '.-..',
  'M': '--',
  'N': '-.',
  'O': '---',
  'P': '.--.',
  'Q': '--.-',
  'R': '.-.',
  'S': '...',
  'T': '-',
  'U': '..-',
  'V': '...-',
  'W': '.--',
  'X': '-..-',
  'Y': '-.--',
  'Z': '--..',
  '0': '-----',
  '1': '.----',
  '2': '..---',
  '3': '...--',
  '4': '....-',
  '5': '.....',
  '6': '-....',
  '7': '--...',
  '8': '---..',
  '9': '----.',
  '.': '.-.-.-',
  ',': '--..--',
  '?': '..--..',
  "'": '.----.',
  '!': '-.-.--',
  '/': '-..-.',
  '(': '-.--.',
  ')': '-.--.-',
  '&': '.-...',
  ':': '---...',
  ';': '-.-.-.',
  '=': '-...-',
  '+': '.-.-.',
  '-': '-....-',
  '_': '..--.-',
  '"': '.-..-.',
  '@': '.--.-.',
};

/// Reverse map: Morse pattern -> character.
final Map<String, String> kMorseToChar = {
  for (final e in kCharToMorse.entries) e.value: e.key,
};

/// Returns the Morse pattern for [char], or null if it is not encodable.
String? morseForChar(String char) => kCharToMorse[char.toUpperCase()];

/// Decodes a Morse pattern (e.g. ".-") to a character, or null if unknown.
String? charForMorse(String pattern) => kMorseToChar[pattern];

/// Order in which letters are introduced by the Listen Tutorial — one letter
/// per level, 26 levels in total. Follows the Koch-method ordering, which
/// front-loads sounds that are easy to tell apart so the ear learns fastest.
const List<String> kTutorialLetterOrder = [
  'K', 'M', 'U', 'R', 'E', 'S', 'N', 'A', 'P', 'T', 'L', 'W', 'I',
  'J', 'Z', 'F', 'O', 'Y', 'V', 'G', 'Q', 'H', 'B', 'C', 'D', 'X',
];


/// Named groups of characters that a training session can draw from.
enum CharacterSet {
  letters('Letters', 'A – Z'),
  numbers('Numbers', '0 – 9'),
  lettersAndNumbers('Letters + Numbers', 'A – Z, 0 – 9'),
  punctuation('Punctuation', '. , ? / = + …'),
  all('Everything', 'letters, numbers, punctuation');

  const CharacterSet(this.label, this.description);
  final String label;
  final String description;

  /// The characters belonging to this set.
  List<String> get characters {
    bool isLetter(String c) => c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 90;
    bool isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
    final keys = kCharToMorse.keys;
    switch (this) {
      case CharacterSet.letters:
        return keys.where(isLetter).toList();
      case CharacterSet.numbers:
        return keys.where(isDigit).toList();
      case CharacterSet.lettersAndNumbers:
        return keys.where((c) => isLetter(c) || isDigit(c)).toList();
      case CharacterSet.punctuation:
        return keys.where((c) => !isLetter(c) && !isDigit(c)).toList();
      case CharacterSet.all:
        return keys.toList();
    }
  }
}
