// lib/parsers/passbook_parser.dart



import '../../../model/bank_details.dart';

/// Manually parses raw OCR text from a bank passbook/document into [BankDetails].
/// No third-party parsing libraries used.
class PassbookParser {
  PassbookParser._();

  /// Main entry point: parses [rawText] from OCR and returns [BankDetails].
  static BankDetails parsePassbook(String rawText) {
    if (rawText.trim().isEmpty) return const BankDetails();

    final normalised = _normalise(rawText);

    final ifscCode = _extractIfsc(normalised);
    final accountNumber = _extractAccountNumber(normalised);
    final accountHolderName = _extractAccountHolderName(normalised);

    return BankDetails(
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
    );
  }

  // ---------------------------------------------------------------------------
  // Normalisation
  // ---------------------------------------------------------------------------

  static String _normalise(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        // Fix OCR O/0 confusion in numeric-only tokens handled per context
        .trim();
  }

  /// Fixes OCR noise in a digit-only context.
  static String _fixDigits(String s) {
    return s
        .replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('I', '1')
        .replaceAll('l', '1')
        .replaceAll('S', '5')
        .replaceAll('B', '8');
  }

  // ---------------------------------------------------------------------------
  // IFSC Code Extraction
  // ---------------------------------------------------------------------------
  // IFSC format: 4 uppercase alpha chars + '0' + 6 alphanumeric chars
  // e.g. SBIN0001234, HDFC0000001

  static String? _extractIfsc(String text) {
    // Primary: standard IFSC pattern
    final ifscPattern = RegExp(
      r'\b([A-Z]{4}0[A-Z0-9]{6})\b',
      caseSensitive: false,
    );

    // Fix common OCR issues before matching
    // Replace 'O' that looks like '0' in the 5th position context
    final textFixed = _fixIfscOcr(text);

    for (final match in ifscPattern.allMatches(textFixed)) {
      final candidate = match.group(1)!.toUpperCase();
      if (_isValidIfsc(candidate)) return candidate;
    }

    // Fallback: look for IFSC label hint
    final labelPattern = RegExp(
      r'IFSC\s*(?:Code|No|Number|:)?\s*[:\-]?\s*([A-Z0-9]{11})',
      caseSensitive: false,
    );
    final labelMatch = labelPattern.firstMatch(textFixed);
    if (labelMatch != null) {
      final candidate = labelMatch.group(1)!.toUpperCase();
      if (_isValidIfsc(candidate)) return candidate;
    }

    return null;
  }

  /// Replaces 'O' with '0' only at position 4 (the mandatory zero in IFSC).
  static String _fixIfscOcr(String text) {
    return text.replaceAllMapped(
      RegExp(r'\b([A-Za-z]{4})[Oo]([A-Za-z0-9]{6})\b'),
      (m) => '${m.group(1)!.toUpperCase()}0${m.group(2)!.toUpperCase()}',
    );
  }

  static bool _isValidIfsc(String code) {
    if (code.length != 11) return false;
    // First 4: alpha, 5th: '0', last 6: alphanumeric
    final pattern = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    return pattern.hasMatch(code);
  }

  // ---------------------------------------------------------------------------
  // Account Number Extraction
  // ---------------------------------------------------------------------------
  // Indian bank account numbers: typically 9–18 digits.
  // Strategy: prefer longer digit sequences; avoid phone/pin/ifsc numbers.

  static String? _extractAccountNumber(String text) {
    final lines = text.split('\n');

    // Priority 1: Look for labelled account number
    final labelPatterns = [
      RegExp(
        r'(?:A/?C|Account|Acct|Acc)\s*(?:No|Number|#|\.)\s*[:\-]?\s*([\dOIlSBo]{9,18})',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:SB|CA|CC|OD)\s*A/?C\s*[:\-]?\s*([\dOIlSBo]{9,18})',
        caseSensitive: false,
      ),
    ];

    for (final line in lines) {
      for (final pattern in labelPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          final digits = _fixDigits(match.group(1)!.replaceAll(RegExp(r'\s'), ''));
          if (_isPlausibleAccountNumber(digits)) return digits;
        }
      }
    }

    // Priority 2: Find all digit sequences of length 9-18, pick best candidate
    final candidates = <String>[];
    final digitPattern = RegExp(r'(?<!\d)([\dOIlSBo]{9,18})(?!\d)');

    for (final match in digitPattern.allMatches(text)) {
      final digits = _fixDigits(match.group(1)!);
      if (_isPlausibleAccountNumber(digits)) {
        candidates.add(digits);
      }
    }

    if (candidates.isEmpty) return null;

    // Prefer candidates 11-16 digits (most common Indian account lengths)
    candidates.sort((a, b) {
      final aScore = _accountNumberScore(a);
      final bScore = _accountNumberScore(b);
      return bScore.compareTo(aScore);
    });

    return candidates.first;
  }

  static bool _isPlausibleAccountNumber(String digits) {
    if (digits.length < 9 || digits.length > 18) return false;
    // Reject if all same digit (e.g. 000000000)
    if (RegExp(r'^(\d)\1+$').hasMatch(digits)) return false;
    // Reject phone-number-like (10 digits starting with 6-9)
    if (digits.length == 10 && RegExp(r'^[6-9]').hasMatch(digits)) return false;
    // Reject PIN codes (6 digits starting with known pin ranges) — too ambiguous, skip
    return true;
  }

  static int _accountNumberScore(String digits) {
    // Scores: prefer 11-16 digit lengths
    final len = digits.length;
    if (len >= 11 && len <= 16) return 10;
    if (len == 9 || len == 10) return 5;
    if (len == 17 || len == 18) return 7;
    return 1;
  }

  // ---------------------------------------------------------------------------
  // Account Holder Name Extraction
  // ---------------------------------------------------------------------------

  static String? _extractAccountHolderName(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Priority 1: Explicit label
    final labelPattern = RegExp(
      r'(?:Name|Account\s*Holder|A/?C\s*Holder|Customer\s*Name)\s*[:\-]?\s*([A-Za-z][A-Za-z\s\.]{4,50})',
      caseSensitive: false,
    );
    for (final line in lines) {
      final match = labelPattern.firstMatch(line);
      if (match != null) {
        final name = _cleanName(match.group(1)!);
        if (name != null) return name;
      }
    }

    // Priority 2: Lines that look like names (2+ words, mostly alpha)
    final skipKeywords = RegExp(
      r'\b(BANK|BRANCH|IFSC|ACCOUNT|STATE|SAVINGS|CURRENT|BALANCE|DATE|PASSBOOK|DEBIT|CREDIT|INTEREST|TRANSACTION|STATEMENT|NATIONAL|INDIA|RESERVE|LIMITED|LTD|PVT)\b',
      caseSensitive: false,
    );
    final namePattern = RegExp(r'^[A-Za-z][A-Za-z\s\.]{4,50}$');

    for (final line in lines) {
      if (RegExp(r'\d').hasMatch(line)) continue; // Skip lines with digits
      if (skipKeywords.hasMatch(line)) continue;
      if (namePattern.hasMatch(line)) {
        final words = line.trim().split(RegExp(r'\s+'));
        if (words.length >= 2) {
          final name = _cleanName(line);
          if (name != null) return name;
        }
      }
    }

    return null;
  }

  static String? _cleanName(String raw) {
    final cleaned = raw
        .replaceAll(RegExp(r'[^A-Za-z\s\.]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length < 5) return null;
    final words = cleaned.split(' ');
    if (words.length < 2) return null;
    // Title case
    return words.map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }
}
