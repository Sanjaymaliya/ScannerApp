
import 'package:equatable/equatable.dart';
import '../../../model/bank_details.dart';

abstract class PassbookScannerState extends Equatable {
  const PassbookScannerState();

  @override
  List<Object?> get props => [];
}

class PassbookScannerInitial extends PassbookScannerState {
  const PassbookScannerInitial();
}

class PassbookScannerLoading extends PassbookScannerState {
  final String message;

  const PassbookScannerLoading({this.message = 'Scanning...'});

  @override
  List<Object?> get props => [message];
}

class PassbookScannerSuccess extends PassbookScannerState {
  final BankDetails bankDetails;
  final String imagePath;
  final String rawText;

  const PassbookScannerSuccess({
    required this.bankDetails,
    required this.imagePath,
    required this.rawText,
  });

  @override
  List<Object?> get props => [bankDetails, imagePath, rawText];
}

class PassbookScannerNoData extends PassbookScannerState {
  final String imagePath;

  const PassbookScannerNoData({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class PassbookScannerError extends PassbookScannerState {
  final String message;

  const PassbookScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
