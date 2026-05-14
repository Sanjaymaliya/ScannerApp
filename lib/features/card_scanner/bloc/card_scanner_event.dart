// lib/bloc/card/card_scanner_event.dart

import 'package:equatable/equatable.dart';

abstract class CardScannerEvent extends Equatable {
  const CardScannerEvent();

  @override
  List<Object?> get props => [];
}

/// User tapped "Scan Card" — opens camera/picker flow
class CardScanStarted extends CardScannerEvent {
  const CardScanStarted();
}

/// Raw OCR text has been extracted from the image
class CardOcrCompleted extends CardScannerEvent {
  final String rawText;
  final String imagePath;

  const CardOcrCompleted({required this.rawText, required this.imagePath});

  @override
  List<Object?> get props => [rawText, imagePath];
}

/// User wants to reset / scan again
class CardScanReset extends CardScannerEvent {
  const CardScanReset();
}

/// An error occurred during scanning
class CardScanErrorOccurred extends CardScannerEvent {
  final String message;

  const CardScanErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
