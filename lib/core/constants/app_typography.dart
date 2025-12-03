// lib/core/constants/app_typography.dart
import 'package:flutter/material.dart';

/// Defines the text styles used throughout the application, based on the Space Grotesk font family.
abstract final class AppTypography {
  static const String _fontFamily = 'SpaceGrotesk';

  // Helper method to create TextStyles with consistent font family and line height calculation
  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing, // Figma's 'Auto' often maps well to Flutter's default
    double? fixedHeight, // Use line height value directly from Figma
    Color? color,
  }) {
    // Figma line height is often absolute, Flutter's height is a multiplier of font size.
    // If fixedHeight is provided, calculate the multiplier.
    final double? heightMultiplier = (fixedHeight != null && fontSize != 0)
        ? fixedHeight / fontSize
        : null;

    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: heightMultiplier, // Use the calculated multiplier
      color: color, // Allow overriding color
    );
  }

  // == Display Styles ==
  static final TextStyle display1 = _baseStyle(
    fontSize: 44,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 44, // 150% of 44
  );
  static final TextStyle display2 = _baseStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 40, // 150% of 40
  );
  static final TextStyle display3 = _baseStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 32, // 150% of 32
  );

  // == Heading Styles ==
  static final TextStyle heading1 = _baseStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 28, // 150% of 28
  );
  static final TextStyle heading2 = _baseStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 24, // 150% of 24
  );
  static final TextStyle heading3 = _baseStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 20, // 150% of 20
  );
  static final TextStyle heading4 = _baseStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 18, // 150% of 18
  );

  // == Feature Styles ==
  static final TextStyle featureBold = _baseStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 120.0 / 100 * 18, // 120% of 18
  );
  static final TextStyle featureMedium = _baseStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
    fixedHeight: 150.0 / 100 * 18, // 150% of 18
  );
  static final TextStyle featureRegular = _baseStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400, // Regular
    fixedHeight: 150.0 / 100 * 18, // 150% of 18
  );

  // == Highlight Styles ==
  static final TextStyle highlightBold = _baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 16, // 150% of 16
  );
  static final TextStyle highlightMedium = _baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    fixedHeight: 150.0 / 100 * 16, // 150% of 16
  );
  static final TextStyle highlightRegular = _baseStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    fixedHeight: 150.0 / 100 * 16, // 150% of 16
  );

  // == Content Styles ==
  static final TextStyle contentBold = _baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 14, // 150% of 14
  );
  static final TextStyle contentMedium = _baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    fixedHeight: 150.0 / 100 * 14, // 150% of 14
  );
  static final TextStyle contentRegular = _baseStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    fixedHeight: 150.0 / 100 * 14, // 150% of 14
  );

  // == Caption Styles ==
  static final TextStyle captionBold = _baseStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 12, // 150% of 12
  );
  static final TextStyle captionMedium = _baseStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
    fixedHeight: 150.0 / 100 * 12, // 150% of 12
  );
  static final TextStyle captionRegular = _baseStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    fixedHeight: 150.0 / 100 * 12, // 150% of 12
  );

  // == Footnote Styles ==
  static final TextStyle footnoteBold = _baseStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700, // Bold
    fixedHeight: 150.0 / 100 * 10, // 150% of 10
  );
  static final TextStyle footnoteMedium = _baseStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
    fixedHeight: 150.0 / 100 * 10, // 150% of 10
  );
  static final TextStyle footnoteRegular = _baseStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400, // Regular
    fixedHeight: 150.0 / 100 * 10, // 150% of 10
  );
}