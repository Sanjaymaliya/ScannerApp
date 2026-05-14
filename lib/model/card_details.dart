// lib/models/card_details.dart

import 'package:equatable/equatable.dart';

class CardDetails extends Equatable {
  final String? cardNumber;
  final String? expiryDate;
  final String? cardHolderName;
  final bool isValid;

  const CardDetails({
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
    this.isValid = false,
  });

  /// Returns masked card number e.g. "XXXX XXXX XXXX 1234"
  String get maskedCardNumber {
    if (cardNumber == null || cardNumber!.length < 4) return '---- ---- ---- ----';
    final digits = cardNumber!.replaceAll(' ', '');
    final last4 = digits.substring(digits.length - 4);
    return 'XXXX XXXX XXXX $last4';
  }

  bool get hasData =>
      cardNumber != null || expiryDate != null || cardHolderName != null;

  CardDetails copyWith({
    String? cardNumber,
    String? expiryDate,
    String? cardHolderName,
    bool? isValid,
  }) {
    return CardDetails(
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [cardNumber, expiryDate, cardHolderName, isValid];

  @override
  String toString() =>
      'CardDetails(cardNumber: $cardNumber, expiry: $expiryDate, name: $cardHolderName, valid: $isValid)';
}
