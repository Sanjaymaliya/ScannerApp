
import 'package:equatable/equatable.dart';
import '../../../model/card_details.dart';

abstract class CardScannerState extends Equatable {
  const CardScannerState();

  @override
  List<Object?> get props => [];
}

/// Initial / idle state
class CardScannerInitial extends CardScannerState {
  const CardScannerInitial();
}

/// Camera / image picker is active or OCR is running
class CardScannerLoading extends CardScannerState {
  final String message;

  const CardScannerLoading({this.message = 'Scanning...'});

  @override
  List<Object?> get props => [message];
}

/// Scan completed successfully with parsed data
class CardScannerSuccess extends CardScannerState {
  final CardDetails cardDetails;
  final String imagePath;
  final String rawText;

  const CardScannerSuccess({
    required this.cardDetails,
    required this.imagePath,
    required this.rawText,
  });

  @override
  List<Object?> get props => [cardDetails, imagePath, rawText];
}

/// Scan completed but no usable data was found
class CardScannerNoData extends CardScannerState {
  final String imagePath;

  const CardScannerNoData({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

/// An error occurred
class CardScannerError extends CardScannerState {
  final String message;

  const CardScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
