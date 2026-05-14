/// Luhn Algorithm implementation (manually implemented, no third-party library)
///
/// The Luhn algorithm works as follows:
/// 1. From the rightmost digit (excluding the check digit) and moving left,
///    double the value of every second digit.
/// 2. If doubling results in a value > 9, subtract 9.
/// 3. Sum all digits.
/// 4. If the total modulo 10 is 0, the number is valid.
class LuhnValidator {
  LuhnValidator._(); // Prevent instantiation

  /// Returns true if [cardNumber] passes the Luhn check.
  /// Accepts digits only (spaces/dashes stripped internally).
  static bool isValidCard(String cardNumber) {
    // Strip all non-digit characters
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty || digits.length < 13 || digits.length > 19) {
      return false;
    }

    int sum = 0;
    bool shouldDouble = false;

    // Traverse from right to left
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);

      if (shouldDouble) {
        digit *= 2;
        if (digit > 9) digit -= 9; // Same as summing the two digits
      }

      sum += digit;
      shouldDouble = !shouldDouble;
    }

    return sum % 10 == 0;
  }
}
