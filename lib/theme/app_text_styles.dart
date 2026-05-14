import 'package:flutter/material.dart';


class AppTextStyles {
  AppTextStyles._();



  // Display
  static const TextStyle txtTitle = TextStyle(
    fontSize: 14,
  );

  static const TextStyle subTitle = TextStyle(
    fontSize: 12,
    letterSpacing: 0.2,
    height: 18 / 12
  );

  // Headings
  static const TextStyle headingLarge = TextStyle(
    fontSize: 14,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(

    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle labelMedium = TextStyle(

    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.3,
  );

  // Logo / Brand
  static const TextStyle logoText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
}
