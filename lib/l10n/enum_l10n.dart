import '../models/settings.dart';
import '../morsey/morse_code.dart';
import 'gen/app_localizations.dart';

/// Localized display strings for the settings enums. Kept out of the model
/// files so those stay free of UI/localization dependencies.

extension AppThemeL10n on AppTheme {
  String label(AppLocalizations l10n) => switch (this) {
        AppTheme.system => l10n.themeSystem,
        AppTheme.light => l10n.themeLight,
        AppTheme.dark => l10n.themeDark,
      };
}

extension DitPaddleL10n on DitPaddle {
  String label(AppLocalizations l10n) => switch (this) {
        DitPaddle.left => l10n.ditPaddleLeft,
        DitPaddle.right => l10n.ditPaddleRight,
      };
}

extension CharacterSetL10n on CharacterSet {
  String label(AppLocalizations l10n) => switch (this) {
        CharacterSet.letters => l10n.charSetLetters,
        CharacterSet.numbers => l10n.charSetNumbers,
        CharacterSet.lettersAndNumbers => l10n.charSetLettersNumbers,
        CharacterSet.punctuation => l10n.charSetPunctuation,
        CharacterSet.all => l10n.charSetAll,
      };

  String description(AppLocalizations l10n) => switch (this) {
        CharacterSet.letters => l10n.charSetLettersDesc,
        CharacterSet.numbers => l10n.charSetNumbersDesc,
        CharacterSet.lettersAndNumbers => l10n.charSetLettersNumbersDesc,
        CharacterSet.punctuation => l10n.charSetPunctuationDesc,
        CharacterSet.all => l10n.charSetAllDesc,
      };
}

extension AppLanguageL10n on AppLanguage {
  /// [AppLanguage.system] is localized; real languages show their endonym so
  /// a user lost in the wrong language can still find their own.
  String label(AppLocalizations l10n) =>
      this == AppLanguage.system ? l10n.languageSystem : endonym!;
}
