

import '../model/card_details.dart';
import 'luhn_validator.dart';

/// Manually parses raw OCR text from a credit/debit card into [CardDetails].
/// No third-party parsing libraries used.
class CardParser {
  CardParser._();

  /// Main entry point: parses [rawText] from OCR and returns [CardDetails].
  static CardDetails parseCard(String rawText) {
    if (rawText.trim().isEmpty) {
      return const CardDetails();
    }

    // Normalise OCR noise: common character confusions
    final normalised = _normaliseOcrText(rawText);

    final cardNumber = _extractCardNumber(normalised);
    final expiryDate = _extractExpiryDate(normalised);
    final cardHolderName = _extractCardHolderName(normalised);
    final isValid = cardNumber != null && LuhnValidator.isValidCard(cardNumber);

    return CardDetails(
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cardHolderName: cardHolderName,
      isValid: isValid,
    );
  }

  // ---------------------------------------------------------------------------
  // OCR Normalisation
  // ---------------------------------------------------------------------------

  /// Fixes common OCR misreads ONLY in numeric contexts.
  /// We do NOT globally replace O→0 or I→1 because that would corrupt names.
  static String _normaliseOcrText(String text) {
    // Preserve original text; only fix within digit-group contexts later.
    return text;
  }

  /// Replaces OCR confusion characters within a digit-only string.
  static String _fixDigitString(String s) {
    return s
        .replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('I', '1')
        .replaceAll('l', '1')
        .replaceAll('S', '5')
        .replaceAll('B', '8')
        .replaceAll('Z', '2');
  }

  // ---------------------------------------------------------------------------
  // Card Number Extraction
  // ---------------------------------------------------------------------------

  static String? _extractCardNumber(String text) {
    final lines = text.split('\n');

    for (final line in lines) {
      final candidate = _findCardNumberInLine(line);
      if (candidate != null) return candidate;
    }

    // Fallback: search entire block
    return _findCardNumberInLine(text.replaceAll('\n', ' '));
  }

  static String? _findCardNumberInLine(String line) {
    // Strip all non-alphanumeric except spaces and dashes
    final cleaned = line.replaceAll(RegExp(r'[^A-Za-z0-9 \-]'), ' ').trim();

    // Pattern 1: Groups of 4 digits separated by spaces or dashes (16-digit cards)
    // Also handles 4-4-4-4, 4-6-5 (Amex style handled below)
    final groupPattern = RegExp(
      r'(?:^|\s)([\dOIlSBZo]{4}[\s\-][\dOIlSBZo]{4}[\s\-][\dOIlSBZo]{4}[\s\-][\dOIlSBZo]{4})(?:\s|$)',
    );
    final groupMatch = groupPattern.firstMatch(cleaned);
    if (groupMatch != null) {
      final raw = groupMatch.group(1)!;
      final digits = _fixDigitString(raw.replaceAll(RegExp(r'[\s\-]'), ''));
      if (digits.length == 16 && LuhnValidator.isValidCard(digits)) {
        return _formatCardNumber(digits);
      }
    }

    // Pattern 2: Continuous 16-digit block (no separators)
    final continuousPattern = RegExp(r'(?<!\d)([\dOIlSBZo]{16})(?!\d)');
    for (final match in continuousPattern.allMatches(cleaned)) {
      final digits = _fixDigitString(match.group(1)!);
      if (LuhnValidator.isValidCard(digits)) {
        return _formatCardNumber(digits);
      }
    }

    // Pattern 3: 15-digit Amex (4-6-5 grouping)
    final amexPattern = RegExp(
      r'(?:^|\s)([\dOIlSBZo]{4}[\s\-][\dOIlSBZo]{6}[\s\-][\dOIlSBZo]{5})(?:\s|$)',
    );
    final amexMatch = amexPattern.firstMatch(cleaned);
    if (amexMatch != null) {
      final raw = amexMatch.group(1)!;
      final digits = _fixDigitString(raw.replaceAll(RegExp(r'[\s\-]'), ''));
      if (digits.length == 15 && LuhnValidator.isValidCard(digits)) {
        return digits; // Amex: return as-is without 4-group format
      }
    }

    // Pattern 4: 13-digit Visa (4-3-3-3)
    final continuousShort = RegExp(r'(?<!\d)([\dOIlSBZo]{13,19})(?!\d)');
    for (final match in continuousShort.allMatches(cleaned)) {
      final digits = _fixDigitString(match.group(1)!);
      if (LuhnValidator.isValidCard(digits)) {
        return _formatCardNumber(digits);
      }
    }

    return null;
  }

  /// Formats a raw digit string into groups of 4 separated by spaces.
  static String _formatCardNumber(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // Expiry Date Extraction
  // ---------------------------------------------------------------------------

  static String? _extractExpiryDate(String text) {
    // Supported formats: MM/YY, MM-YY, MM/YYYY, MM-YYYY, MMYY (e.g. 1225)
    final patterns = [
      // MM/YY or MM/YYYY or MM-YY or MM-YYYY
      RegExp(r'\b(0[1-9]|1[0-2])[\/\-](2[0-9]|20[2-9][0-9])\b'),
      // MMYY compact (e.g. 1225) — must be 4 digits, month 01-12
      RegExp(r'\b(0[1-9]|1[0-2])([2-9][5-9])\b'),
      // Expiry label hint
      RegExp(
        r'(?:VALID\s*THRU|EXPIRES?|EXP|THRU)[^\d]*(0[1-9]|1[0-2])[\/\-\s]*(2[0-9]|20[2-9][0-9])',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final month = match.group(1)!;
        final year = match.group(2)!;
        final fullYear = year.length == 2 ? '20$year' : year;
        // Validate not in past
        if (_isExpiryValid(month, fullYear)) {
          return '$month/${year.length == 2 ? year : year.substring(2)}';
        }
      }
    }

    return null;
  }

  static bool _isExpiryValid(String month, String year) {
    final now = DateTime.now();
    final m = int.tryParse(month) ?? 0;
    final y = int.tryParse(year) ?? 0;
    if (m < 1 || m > 12 || y < 2000) return false;
    final expiry = DateTime(y, m + 1, 0); // Last day of the expiry month
    return expiry.isAfter(now);
  }

  // ---------------------------------------------------------------------------
  // Card Holder Name Extraction
  // ---------------------------------------------------------------------------

  static String? _extractCardHolderName(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Heuristic: card holder name is an ALL-CAPS line of 2+ words, no digits
    // Usually appears in the lower half of the card text
    final namePattern = RegExp(r'^[A-Z][A-Z\s\.\-]{4,}$');

    // Skip lines that look like bank names, card types, etc.
    final skipKeywords = RegExp(
      r'\b(VISA|MASTERCARD|RUPAY|AMEX|BANK|CREDIT|DEBIT|CARD|PLATINUM|GOLD|CLASSIC|MEMBER|SINCE)\b',
      caseSensitive: false,
    );

    for (final line in lines) {
      // Must be letters and spaces only (no digits)
      if (RegExp(r'\d').hasMatch(line)) continue;
      if (skipKeywords.hasMatch(line)) continue;
      if (namePattern.hasMatch(line)) {
        final words = line.trim().split(RegExp(r'\s+'));
        if (words.length >= 2 && words.every((w) => w.length >= 1)) {
          return _toTitleCase(line.trim());
        }
      }
    }

    // Fallback: Look for "Mr." / "Mrs." prefix
    final prefixPattern = RegExp(
      r'\b(Mr|Mrs|Ms|Dr)\.?\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)+)',
      caseSensitive: false,
    );
    final prefixMatch = prefixPattern.firstMatch(text);
    if (prefixMatch != null) {
      return prefixMatch.group(0)!.trim();
    }

    return null;
  }

  static String _toTitleCase(String s) {
    return s.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
