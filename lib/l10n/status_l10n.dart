import '../input/combined_paddle_source.dart';
import '../input/paddle_source.dart';
import 'gen/app_localizations.dart';

/// Renders the paddle sources' structured status as localized display text.
/// Kept here (not in the input layer) so the sources stay free of UI and
/// localization dependencies.

extension PaddleStatusL10n on PaddleStatus {
  String text(AppLocalizations l10n) => switch (kind) {
        PaddleStatusKind.idle ||
        PaddleStatusKind.usbWaiting =>
          l10n.statusUsbWaiting,
        PaddleStatusKind.keyboardReady => l10n.statusKeyboardReady,
        PaddleStatusKind.usbConnected =>
          l10n.statusUsbConnected(detail ?? ''),
        PaddleStatusKind.usbUnplugged => l10n.statusUsbUnplugged,
        PaddleStatusKind.usbOpenFailed =>
          l10n.statusUsbOpenFailed(detail ?? '', error ?? ''),
        PaddleStatusKind.usbOpenDenied =>
          l10n.statusUsbOpenDenied(error ?? ''),
        PaddleStatusKind.usbError => l10n.statusUsbError(error ?? ''),
      };
}

extension CombinedPaddleSourceL10n on CombinedPaddleSource {
  /// The one-line status shown above the keying screens.
  String statusText(AppLocalizations l10n) {
    if (!hasUsb) return l10n.statusPaddlesTouch;
    if (usbConnected) return l10n.statusUsbAndKeyboard(status.text(l10n));
    return l10n.statusKeyboardAndUsb(status.text(l10n));
  }
}
