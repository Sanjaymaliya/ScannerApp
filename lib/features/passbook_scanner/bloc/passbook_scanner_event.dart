// lib/bloc/passbook/passbook_scanner_event.dart

import 'package:equatable/equatable.dart';

abstract class PassbookScannerEvent extends Equatable {
  const PassbookScannerEvent();

  @override
  List<Object?> get props => [];
}

class PassbookScanFromCamera extends PassbookScannerEvent {
  const PassbookScanFromCamera();
}

class PassbookScanFromGallery extends PassbookScannerEvent {
  const PassbookScanFromGallery();
}

class PassbookOcrCompleted extends PassbookScannerEvent {
  final String rawText;
  final String imagePath;

  const PassbookOcrCompleted({required this.rawText, required this.imagePath});

  @override
  List<Object?> get props => [rawText, imagePath];
}

class PassbookScanReset extends PassbookScannerEvent {
  const PassbookScanReset();
}

class PassbookScanErrorOccurred extends PassbookScannerEvent {
  final String message;

  const PassbookScanErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
