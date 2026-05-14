

import 'package:equatable/equatable.dart';

class BankDetails extends Equatable {
  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;

  const BankDetails({
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
  });

  bool get hasData =>
      accountHolderName != null || accountNumber != null || ifscCode != null;

  BankDetails copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
  }) {
    return BankDetails(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
    );
  }

  @override
  List<Object?> get props => [accountHolderName, accountNumber, ifscCode];

  @override
  String toString() =>
      'BankDetails(name: $accountHolderName, account: $accountNumber, ifsc: $ifscCode)';
}
